#include "spruce_igm_theme.h"
#include "spruce_igm_platform.h"

#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#include <compat/strl.h>
#include <file/file_path.h>
#include <formats/rjson.h>
#include <streams/file_stream.h>
#include <string/stdstring.h>

#include "verbosity.h"

/* Sections of the file. Nesting is exactly two deep, so a single enum plus the
 * current member name is all the state the parser needs. */
enum igm_section
{
   SEC_ROOT = 0,
   SEC_COLORS,
   SEC_LAYOUT,
   SEC_FONT,
   SEC_TEXT,
   SEC_LABELS,
   SEC_UNKNOWN
};

typedef struct
{
   spruce_igm_theme_t *t;
   const char         *path;      /* for messages, and to resolve font_path */
   enum igm_section    section;
   int                 depth;
   char                member[48];
   unsigned            applied;
   unsigned            rejected;
} igm_parse_ctx;

static spruce_igm_theme_t s_theme;
static spruce_igm_theme_t s_scratch;
static bool               s_loaded;

/* ── Colour plumbing ───────────────────────────────────────── */

uint32_t spruce_igm_theme_color_rgba(const spruce_igm_theme_t *t, int id)
{
   if (!t || id < 0 || id >= IGM_COL_COUNT)
      return 0xFFFFFFFFu;
   return t->rgba[id];
}

uint32_t spruce_igm_theme_color_argb(const spruce_igm_theme_t *t, int id)
{
   uint32_t c = spruce_igm_theme_color_rgba(t, id);
   return (c << 24) | (c >> 8);
}

void spruce_igm_theme_color_float(const spruce_igm_theme_t *t, int id,
      float out[16])
{
   uint32_t c = spruce_igm_theme_color_rgba(t, id);
   float    r = ((c >> 24) & 0xFF) * (1.0f / 255.0f);
   float    g = ((c >> 16) & 0xFF) * (1.0f / 255.0f);
   float    b = ((c >>  8) & 0xFF) * (1.0f / 255.0f);
   float    a = ( c        & 0xFF) * (1.0f / 255.0f);
   int      i;

   for (i = 0; i < 16; i += 4)
   {
      out[i    ] = r;
      out[i + 1] = g;
      out[i + 2] = b;
      out[i + 3] = a;
   }
}

/*
 * "#RRGGBB", "#RRGGBBAA", with or without the '#', and 0x-prefixed. Six digits
 * imply an opaque alpha.
 *
 * Not string_hex_to_unsigned(): that returns 0 both for a parse failure and for
 * a legitimate #000000, which is exactly the distinction a merge-over-defaults
 * loader needs to make.
 */
static bool igm_parse_color(const char *s, uint32_t *out)
{
   char          buf[9];
   size_t        n, i;
   unsigned long v;

   if (!s)
      return false;

   if (*s == '#')
      s++;
   else if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X'))
      s += 2;

   n = strlen(s);
   if (n != 6 && n != 8)
      return false;

   for (i = 0; i < n; i++)
      if (!isxdigit((unsigned char)s[i]))
         return false;

   memcpy(buf, s, n);
   buf[n] = '\0';
   v      = strtoul(buf, NULL, 16);

   *out = (n == 6) ? (uint32_t)((v << 8) | 0xFF) : (uint32_t)v;
   return true;
}

/* ── Defaults ──────────────────────────────────────────────── */

/*
 * These must stay byte-for-byte equal to RetroArch/igm/spruce.json in the
 * spruceOS repo. The whole test for this feature is that the menu looks the
 * same with that file present and absent.
 *
 * Alphas are 8-bit here where the old code used a float literal (0.85f became
 * 0xD9, i.e. 0.85098) so that the JSON can express them exactly. The 0.1%
 * difference is not visible.
 */
static void igm_theme_set_defaults(spruce_igm_theme_t *t)
{
   int i;

   memset(t, 0, sizeof(*t));

   t->rgba[IGM_COL_DIM_BG]        = 0x000000D9u;
   t->rgba[IGM_COL_PANEL_BG]      = 0x00000000u;
   t->rgba[IGM_COL_SELECTION]     = 0xC9A2272Eu;
   t->rgba[IGM_COL_ACCENT]        = 0xC9A227D9u;
   t->rgba[IGM_COL_TITLE_LINE]    = 0x665C5466u;
   t->rgba[IGM_COL_TEXT]          = 0xBDAD91FFu;
   t->rgba[IGM_COL_TEXT_SELECTED] = 0xD5C4A1FFu;
   t->rgba[IGM_COL_TEXT_TITLE]    = 0x689D6AFFu;
   t->rgba[IGM_COL_TEXT_SHADOW]   = 0x000000C0u;
   t->rgba[IGM_COL_BATTERY]       = 0xBDAD91FFu;

   t->margin_pct          = 2.0f;
   t->panel_w_pct         = 38.0f;
   t->item_h_pct          = 8.0f;
   t->title_h_pct         = 8.0f;
   t->panel_x_auto        = true;
   t->panel_y_auto        = true;
   t->separator_inset_pct = 10.0f;
   t->arrow_inset_pct     = 10.0f;
   t->accent_w_pct        = 100.0f / 80.0f;
   t->separator_h_px      = 1;
   t->shadow_offset_px    = 2;
   t->text_baseline       = 0.68f;
   t->title_baseline      = 0.68f;
   t->scale               = 1.0f;
   t->accent_bar          = true;
   t->shadow              = true;
   t->show_battery        = true;
   t->show_preview        = true;

   /* 100/20 and 100/28 - the divisors the hardcoded code used. */
   t->font_size_pct         = 100.0f / 20.0f;
   t->font_size_small_pct   = 100.0f / 28.0f;
   t->font_battery_size_pct = 100.0f / 28.0f;
   strlcpy(t->font_path, IGM_FONT_PRIMARY, sizeof(t->font_path));

   strlcpy(t->title,       "spruceOS Menu",  sizeof(t->title));
   for (i = 0; i < IGM_ID_COUNT; i++)
      strlcpy(t->labels[i], spruce_igm_item_default_label(i),
            sizeof(t->labels[i]));
   strlcpy(t->auto_label,  "Auto",           sizeof(t->auto_label));
   strlcpy(t->slot_label,  "Slot",           sizeof(t->slot_label));
   strlcpy(t->max_label,   "Max",            sizeof(t->max_label));
   strlcpy(t->on_label,    "On",             sizeof(t->on_label));
   strlcpy(t->off_label,   "Off",            sizeof(t->off_label));
   strlcpy(t->arrow_left,  "<",              sizeof(t->arrow_left));
   strlcpy(t->arrow_right, ">",              sizeof(t->arrow_right));
}

/* ── Key tables ────────────────────────────────────────────── */

static const struct { const char *key; int id; } igm_color_keys[] = {
   { "dim_bg",        IGM_COL_DIM_BG        },
   { "panel_bg",      IGM_COL_PANEL_BG      },
   { "selection",     IGM_COL_SELECTION     },
   { "accent",        IGM_COL_ACCENT        },
   { "title_line",    IGM_COL_TITLE_LINE    },
   { "text",          IGM_COL_TEXT          },
   { "text_selected", IGM_COL_TEXT_SELECTED },
   { "text_title",    IGM_COL_TEXT_TITLE    },
   { "text_shadow",   IGM_COL_TEXT_SHADOW   },
   { "battery",       IGM_COL_BATTERY       },
};

/* ── Handlers ──────────────────────────────────────────────── */

static bool igm_on_member(void *data, const char *s, size_t len)
{
   igm_parse_ctx *c = (igm_parse_ctx*)data;
   strlcpy(c->member, s, sizeof(c->member));
   (void)len;
   return true;
}

static bool igm_on_object_start(void *data)
{
   igm_parse_ctx *c = (igm_parse_ctx*)data;

   c->depth++;
   if (c->depth == 2)
   {
      if      (string_is_equal(c->member, "colors")) c->section = SEC_COLORS;
      else if (string_is_equal(c->member, "layout")) c->section = SEC_LAYOUT;
      else if (string_is_equal(c->member, "font"))   c->section = SEC_FONT;
      else if (string_is_equal(c->member, "text"))   c->section = SEC_TEXT;
      else if (string_is_equal(c->member, "labels")) c->section = SEC_LABELS;
      else                                           c->section = SEC_UNKNOWN;
   }
   c->member[0] = '\0';
   return true;
}

static bool igm_on_object_end(void *data)
{
   igm_parse_ctx *c = (igm_parse_ctx*)data;

   c->depth--;
   if (c->depth <= 1)
      c->section = SEC_ROOT;
   c->member[0] = '\0';
   return true;
}

static bool igm_on_string(void *data, const char *s, size_t len)
{
   igm_parse_ctx      *c = (igm_parse_ctx*)data;
   spruce_igm_theme_t *t = c->t;
   size_t              i;

   (void)len;

   switch (c->section)
   {
      case SEC_COLORS:
         for (i = 0; i < ARRAY_SIZE(igm_color_keys); i++)
         {
            if (!string_is_equal(c->member, igm_color_keys[i].key))
               continue;
            if (igm_parse_color(s, &t->rgba[igm_color_keys[i].id]))
               c->applied++;
            else
            {
               c->rejected++;
               RARCH_WARN("[IGM theme] \"%s\": bad colour \"%s\" for "
                     "colors.%s - keeping the default.\n",
                     c->path, s, igm_color_keys[i].key);
            }
            return true;
         }
         break;

      case SEC_FONT:
         if (string_is_equal(c->member, "path"))
         {
            /* Relative to the file that named it, so a theme's "nunwen.ttf"
             * means the one in that theme. */
            fill_pathname_resolve_relative(t->font_path, c->path, s,
                  sizeof(t->font_path));
            c->applied++;
         }
         break;

      case SEC_TEXT:
         if      (string_is_equal(c->member, "title"))
         { strlcpy(t->title, s, sizeof(t->title)); c->applied++; }
         else if (string_is_equal(c->member, "auto"))
         { strlcpy(t->auto_label, s, sizeof(t->auto_label)); c->applied++; }
         else if (string_is_equal(c->member, "slot"))
         { strlcpy(t->slot_label, s, sizeof(t->slot_label)); c->applied++; }
         else if (string_is_equal(c->member, "max"))
         { strlcpy(t->max_label, s, sizeof(t->max_label)); c->applied++; }
         else if (string_is_equal(c->member, "on"))
         { strlcpy(t->on_label, s, sizeof(t->on_label)); c->applied++; }
         else if (string_is_equal(c->member, "off"))
         { strlcpy(t->off_label, s, sizeof(t->off_label)); c->applied++; }
         else if (string_is_equal(c->member, "arrow_left"))
         { strlcpy(t->arrow_left, s, sizeof(t->arrow_left)); c->applied++; }
         else if (string_is_equal(c->member, "arrow_right"))
         { strlcpy(t->arrow_right, s, sizeof(t->arrow_right)); c->applied++; }
         break;

      case SEC_LABELS:
         for (i = 0; i < IGM_ID_COUNT; i++)
         {
            if (!string_is_equal(c->member, spruce_igm_item_key(i)))
               continue;
            strlcpy(t->labels[i], s, sizeof(t->labels[i]));
            c->applied++;
            return true;
         }
         break;

      default:
         break;
   }
   return true;
}

static bool igm_on_number(void *data, const char *s, size_t len)
{
   igm_parse_ctx      *c = (igm_parse_ctx*)data;
   spruce_igm_theme_t *t = c->t;
   float               v = (float)atof(s);

   (void)len;

   switch (c->section)
   {
      case SEC_LAYOUT:
         if      (string_is_equal(c->member, "margin_pct"))
            t->margin_pct = v;
         else if (string_is_equal(c->member, "panel_w_pct"))
            t->panel_w_pct = v;
         else if (string_is_equal(c->member, "item_h_pct"))
            t->item_h_pct = v;
         else if (string_is_equal(c->member, "title_h_pct"))
            t->title_h_pct = v;
         else if (string_is_equal(c->member, "panel_x_pct"))
         { t->panel_x_pct = v; t->panel_x_auto = false; }
         else if (string_is_equal(c->member, "panel_y_pct"))
         { t->panel_y_pct = v; t->panel_y_auto = false; }
         else if (string_is_equal(c->member, "separator_inset_pct"))
            t->separator_inset_pct = v;
         else if (string_is_equal(c->member, "arrow_inset_pct"))
            t->arrow_inset_pct = v;
         else if (string_is_equal(c->member, "accent_w_pct"))
            t->accent_w_pct = v;
         else if (string_is_equal(c->member, "separator_h_px"))
            t->separator_h_px = (int)v;
         else if (string_is_equal(c->member, "shadow_offset_px"))
            t->shadow_offset_px = (int)v;
         else if (string_is_equal(c->member, "text_baseline"))
            t->text_baseline = v;
         else if (string_is_equal(c->member, "title_baseline"))
            t->title_baseline = v;
         else if (string_is_equal(c->member, "scale"))
            t->scale = v;
         else
            return true;
         c->applied++;
         break;

      case SEC_FONT:
         if      (string_is_equal(c->member, "size_pct"))
            t->font_size_pct = v;
         else if (string_is_equal(c->member, "size_small_pct"))
            t->font_size_small_pct = v;
         else if (string_is_equal(c->member, "battery_size_pct"))
            t->font_battery_size_pct = v;
         else
            return true;
         c->applied++;
         break;

      default:
         break;
   }
   return true;
}

static bool igm_on_bool(void *data, bool value)
{
   igm_parse_ctx      *c = (igm_parse_ctx*)data;
   spruce_igm_theme_t *t = c->t;

   if (c->section != SEC_LAYOUT)
      return true;

   if      (string_is_equal(c->member, "accent_bar")) t->accent_bar   = value;
   else if (string_is_equal(c->member, "shadow"))     t->shadow       = value;
   else if (string_is_equal(c->member, "battery"))    t->show_battery = value;
   else if (string_is_equal(c->member, "preview"))    t->show_preview = value;
   else return true;

   c->applied++;
   return true;
}

/* A null means "use the default", which is what the scratch already holds.
 * spruce.json writes panel_x_pct/panel_y_pct as null to say "auto". */
static bool igm_on_null(void *data)
{
   (void)data;
   return true;
}

/* ── Loading ───────────────────────────────────────────────── */

/* Returns true if the file existed, whether or not it parsed - a present but
 * broken file stops the search rather than falling through to the next
 * candidate, so "first hit wins" holds even when the hit is malformed. */
static bool igm_theme_load_file(spruce_igm_theme_t *dst, const char *path)
{
   igm_parse_ctx   ctx;
   RFILE          *f;
   rjson_t        *parser;
   enum rjson_type r;

   if (!path_is_valid(path))
      return false;

   if (!(f = filestream_open(path, RETRO_VFS_FILE_ACCESS_READ,
               RETRO_VFS_FILE_ACCESS_HINT_NONE)))
   {
      RARCH_WARN("[IGM theme] \"%s\" could not be opened.\n", path);
      return true;
   }

   if (!(parser = rjson_open_rfile(f)))
   {
      filestream_close(f);
      RARCH_WARN("[IGM theme] \"%s\": no parser.\n", path);
      return true;
   }

   /* Parse into a scratch copy of the defaults. Only a clean RJSON_DONE gets
    * committed, so a truncated file leaves the built-in look rather than half
    * of a theme. */
   igm_theme_set_defaults(&s_scratch);

   memset(&ctx, 0, sizeof(ctx));
   ctx.t       = &s_scratch;
   ctx.path    = path;
   ctx.section = SEC_ROOT;

   rjson_set_options(parser,
         RJSON_OPTION_ALLOW_UTF8BOM | RJSON_OPTION_ALLOW_COMMENTS);

   r = rjson_parse(parser, &ctx,
         igm_on_member,
         igm_on_string,
         igm_on_number,
         igm_on_object_start,
         igm_on_object_end,
         NULL,            /* arrays are not part of the schema */
         NULL,
         igm_on_bool,
         igm_on_null);

   if (r == RJSON_DONE)
   {
      strlcpy(s_scratch.source_path, path, sizeof(s_scratch.source_path));
      memcpy(dst, &s_scratch, sizeof(*dst));
      RARCH_LOG("[IGM theme] Loaded \"%s\" (%u keys applied, %u rejected).\n",
            path, ctx.applied, ctx.rejected);
   }
   else
      RARCH_WARN("[IGM theme] \"%s\": invalid JSON at line %d, column %d (%s)"
            " - using the built-in look.\n",
            path,
            (int)rjson_get_source_line(parser),
            (int)rjson_get_source_column(parser),
            rjson_get_error(parser));

   rjson_free(parser);
   filestream_close(f);
   return true;
}

void spruce_igm_theme_reload(void)
{
   const char *env;
   char        path[PATH_MAX_LENGTH];

   s_loaded = true;
   igm_theme_set_defaults(&s_theme);

   /* 1. the active theme, handed to us by the launch script */
   if ((env = getenv("SPRUCE_THEME_DIR")) && *env)
   {
      fill_pathname_join_special(path, env, "igm.json", sizeof(path));
      if (igm_theme_load_file(&s_theme, path))
         return;
   }

   /* 2. whatever the settings colourway picker last wrote */
   fill_pathname_join_special(path, IGM_BASE_DIR, "igm.json", sizeof(path));
   if (igm_theme_load_file(&s_theme, path))
      return;

   /* 3. the shipped default, so a card that has never touched the setting
    *    still reads a real file and needs no migration */
   fill_pathname_join_special(path, IGM_BASE_DIR, "igm/spruce.json",
         sizeof(path));
   if (igm_theme_load_file(&s_theme, path))
      return;

   RARCH_LOG("[IGM theme] No igm.json found; using the built-in look.\n");
}

const spruce_igm_theme_t *spruce_igm_theme_get(void)
{
   if (!s_loaded)
      spruce_igm_theme_reload();
   return &s_theme;
}
