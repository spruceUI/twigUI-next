#include "spruce_igm_items.h"
#include "spruce_igm_platform.h"
#include "spruce_igm_theme.h"

#include <stdio.h>
#include <string.h>

#include <file/config_file.h>
#include <file/file_path.h>
#include <formats/rjson.h>
#include <streams/file_stream.h>
#include <string/stdstring.h>

#include "audio/audio_driver.h"
#include "command.h"
#include "configuration.h"
#include "disk_control_interface.h"
#include "gfx/video_shader_parse.h"
#include "paths.h"
#include "runloop.h"
#include "verbosity.h"

#define IGM_FF_MIN      2
#define IGM_FF_MAX      10
#define IGM_FF_UNCAPPED (IGM_FF_MAX + 1)

#if defined(HAVE_CG) || defined(HAVE_GLSL) || defined(HAVE_SLANG) || defined(HAVE_HLSL)
#define IGM_HAVE_SHADERS 1
#endif

static const struct
{
   const char *key;
   const char *label;
} igm_items[IGM_ID_COUNT] = {
   { "resume",     "Resume"         },
   { "save",       "Save"           },
   { "load",       "Load"           },
   { "ff_speed",   "FF Speed"       },
   { "reset",      "Reset"          },
   { "retroarch",  "RetroArch Menu" },
   { "exit",       "Exit Game"      },
   { "disc",       "Disc"           },
   { "screenshot", "Screenshot"     },
   { "undo_save",  "Undo Save"      },
   { "undo_load",  "Undo Load"      },
   { "show_fps",   "Show FPS"       },
   { "mute",       "Mute"           },
   { "rewind",     "Rewind"         },
   { "shader",     "Shader"         },
};

static const int igm_default_list[] = {
   IGM_ID_RESUME, IGM_ID_SAVE, IGM_ID_LOAD, IGM_ID_FF_SPEED,
   IGM_ID_RESET, IGM_ID_RETROARCH, IGM_ID_EXIT
};

static int  s_list[IGM_ID_COUNT];
static int  s_list_count;
static bool s_list_loaded;

static struct
{
   float ff_ratio;
   bool  fps_show;
   bool  rewind;
   bool  shader;
} s_open;

static unsigned s_disc_sel;

const char *spruce_igm_item_key(int id)
{
   return (id >= 0 && id < IGM_ID_COUNT) ? igm_items[id].key : "";
}

const char *spruce_igm_item_default_label(int id)
{
   return (id >= 0 && id < IGM_ID_COUNT) ? igm_items[id].label : "";
}

/* ── igm_items.json ────────────────────────────────────────── */

typedef struct
{
   int  list[IGM_ID_COUNT];
   int  count;
   int  depth;
   bool in_items;
   char member[24];
} igm_list_ctx;

static bool igm_list_on_member(void *data, const char *s, size_t len)
{
   igm_list_ctx *c = (igm_list_ctx*)data;
   strlcpy(c->member, s, sizeof(c->member));
   (void)len;
   return true;
}

static bool igm_list_on_object_start(void *data)
{
   ((igm_list_ctx*)data)->depth++;
   return true;
}

static bool igm_list_on_object_end(void *data)
{
   ((igm_list_ctx*)data)->depth--;
   return true;
}

static bool igm_list_on_array_start(void *data)
{
   igm_list_ctx *c = (igm_list_ctx*)data;
   c->depth++;
   if (c->depth == 2 && string_is_equal(c->member, "items"))
      c->in_items = true;
   return true;
}

static bool igm_list_on_array_end(void *data)
{
   igm_list_ctx *c = (igm_list_ctx*)data;
   if (c->depth == 2)
      c->in_items = false;
   c->depth--;
   return true;
}

static bool igm_list_on_string(void *data, const char *s, size_t len)
{
   igm_list_ctx *c = (igm_list_ctx*)data;
   int id, i;

   (void)len;
   if (!c->in_items || c->depth != 2)
      return true;

   for (id = 0; id < IGM_ID_COUNT; id++)
      if (string_is_equal(s, igm_items[id].key))
         break;
   if (id == IGM_ID_COUNT)
   {
      RARCH_WARN("[IGM items] Unknown item \"%s\" skipped.\n", s);
      return true;
   }

   for (i = 0; i < c->count; i++)
      if (c->list[i] == id)
         return true;
   c->list[c->count++] = id;
   return true;
}

/* Resume always first and Exit always last, wherever the file put them */
static void igm_list_pin_ends(int *list, int count)
{
   int i, n = 0, out[IGM_ID_COUNT];
   bool resume = false, quit = false;

   for (i = 0; i < count; i++)
   {
      if (list[i] == IGM_ID_RESUME)
         resume = true;
      else if (list[i] == IGM_ID_EXIT)
         quit = true;
   }
   if (resume)
      out[n++] = IGM_ID_RESUME;
   for (i = 0; i < count; i++)
      if (list[i] != IGM_ID_RESUME && list[i] != IGM_ID_EXIT)
         out[n++] = list[i];
   if (quit)
      out[n++] = IGM_ID_EXIT;
   memcpy(list, out, sizeof(int) * n);
}

static void igm_list_set_default(void)
{
   memcpy(s_list, igm_default_list, sizeof(igm_default_list));
   s_list_count = (int)ARRAY_SIZE(igm_default_list);
}

static void igm_list_load(void)
{
   char            path[PATH_MAX_LENGTH];
   igm_list_ctx    ctx;
   RFILE          *f;
   rjson_t        *parser;
   enum rjson_type r;

   s_list_loaded = true;
   igm_list_set_default();

   fill_pathname_join_special(path, IGM_BASE_DIR, "igm_items.json",
         sizeof(path));
   if (!path_is_valid(path))
      return;
   if (!(f = filestream_open(path, RETRO_VFS_FILE_ACCESS_READ,
               RETRO_VFS_FILE_ACCESS_HINT_NONE)))
      return;
   if (!(parser = rjson_open_rfile(f)))
   {
      filestream_close(f);
      return;
   }

   memset(&ctx, 0, sizeof(ctx));
   rjson_set_options(parser,
         RJSON_OPTION_ALLOW_UTF8BOM | RJSON_OPTION_ALLOW_COMMENTS);
   r = rjson_parse(parser, &ctx,
         igm_list_on_member,
         igm_list_on_string,
         NULL,
         igm_list_on_object_start,
         igm_list_on_object_end,
         igm_list_on_array_start,
         igm_list_on_array_end,
         NULL,
         NULL);

   if (r != RJSON_DONE)
      RARCH_WARN("[IGM items] \"%s\": invalid JSON at line %d, column %d (%s)"
            " - using the default list.\n", path,
            (int)rjson_get_source_line(parser),
            (int)rjson_get_source_column(parser),
            rjson_get_error(parser));
   else if (ctx.count == 0)
      RARCH_WARN("[IGM items] \"%s\": no items - using the default list.\n",
            path);
   else
   {
      igm_list_pin_ends(ctx.list, ctx.count);
      memcpy(s_list, ctx.list, sizeof(s_list));
      s_list_count = ctx.count;
      RARCH_LOG("[IGM items] Loaded \"%s\" (%d items).\n", path, ctx.count);
   }

   rjson_free(parser);
   filestream_close(f);
}

/* ── Open / close ──────────────────────────────────────────── */

static disk_control_interface_t *igm_disk(void)
{
   return &runloop_state_get_ptr()->system.disk_control;
}

static bool igm_item_available(int id)
{
   switch (id)
   {
      case IGM_ID_DISC:
         return disk_control_enabled(igm_disk())
            && disk_control_get_num_images(igm_disk()) > 1;
      case IGM_ID_SCREENSHOT:
#ifdef HAVE_SCREENSHOTS
         return true;
#else
         return false;
#endif
      case IGM_ID_REWIND:
#ifdef HAVE_REWIND
         return true;
#else
         return false;
#endif
      case IGM_ID_SHADER:
#ifdef IGM_HAVE_SHADERS
         return true;
#else
         return false;
#endif
      default:
         return true;
   }
}

int spruce_igm_items_open(int *rows, int max)
{
   settings_t *settings = config_get_ptr();
   int i, n = 0;

   if (!s_list_loaded)
      igm_list_load();

   s_open.ff_ratio = settings->floats.fastforward_ratio;
   s_open.fps_show = settings->bools.video_fps_show;
   s_open.rewind   = settings->bools.rewind_enable;
   s_open.shader   = settings->bools.video_shader_enable;

   s_disc_sel = disk_control_get_image_index(igm_disk());

   for (i = 0; i < s_list_count && n < max; i++)
      if (igm_item_available(s_list[i]))
         rows[n++] = s_list[i];

   if (n == 0 && max > 0)
      rows[n++] = IGM_ID_RESUME;
   return n;
}

/* Single keys only: config_save_on_exit is off, and a full save would fold any
 * --appendconfig overlay into the main config. */
void spruce_igm_items_close(void)
{
   settings_t *settings = config_get_ptr();
   const char *path     = path_get(RARCH_PATH_CONFIG);
   bool ff     = settings->floats.fastforward_ratio != s_open.ff_ratio;
   bool fps    = settings->bools.video_fps_show     != s_open.fps_show;
   bool rewind = settings->bools.rewind_enable      != s_open.rewind;
   bool shader = settings->bools.video_shader_enable != s_open.shader;
   config_file_t *conf;

   if (!(ff || fps || rewind || shader) || string_is_empty(path))
      return;
   if (!(conf = config_file_new_from_path_to_string(path)))
      return;

   if (ff)
      config_set_float(conf, "fastforward_ratio",
            settings->floats.fastforward_ratio);
   if (fps)
      config_set_string(conf, "fps_show",
            settings->bools.video_fps_show ? "true" : "false");
   if (rewind)
      config_set_string(conf, "rewind_enable",
            settings->bools.rewind_enable ? "true" : "false");
   if (shader)
      config_set_string(conf, "video_shader_enable",
            settings->bools.video_shader_enable ? "true" : "false");

   if (config_file_write(conf, path, false))
   {
      s_open.ff_ratio = settings->floats.fastforward_ratio;
      s_open.fps_show = settings->bools.video_fps_show;
      s_open.rewind   = settings->bools.rewind_enable;
      s_open.shader   = settings->bools.video_shader_enable;
   }
   config_file_free(conf);
}

/* ── Per-item behaviour ────────────────────────────────────── */

static int igm_ff_step_of(float ratio)
{
   int n;
   if (ratio < 1.0f)
      return IGM_FF_UNCAPPED;
   n = (int)(ratio + 0.5f);
   if (n < IGM_FF_MIN)
      return IGM_FF_MIN;
   if (n > IGM_FF_MAX)
      return IGM_FF_MAX;
   return n;
}

bool spruce_igm_item_has_arrows(int id)
{
   return id == IGM_ID_SAVE || id == IGM_ID_LOAD
       || id == IGM_ID_FF_SPEED || id == IGM_ID_DISC;
}

void spruce_igm_item_step(int id, int dir)
{
   settings_t *settings = config_get_ptr();

   switch (id)
   {
      case IGM_ID_SAVE:
      case IGM_ID_LOAD:
         command_event(dir < 0 ? CMD_EVENT_SAVE_STATE_DECREMENT
                               : CMD_EVENT_SAVE_STATE_INCREMENT, NULL);
         break;
      case IGM_ID_FF_SPEED:
         {
            int n = igm_ff_step_of(settings->floats.fastforward_ratio) + dir;
            if (n < IGM_FF_MIN)
               n = IGM_FF_MIN;
            if (n > IGM_FF_UNCAPPED)
               n = IGM_FF_UNCAPPED;
            configuration_set_float(settings,
                  settings->floats.fastforward_ratio,
                  n == IGM_FF_UNCAPPED ? 0.0f : (float)n);
         }
         break;
      case IGM_ID_DISC:
         {
            unsigned num = disk_control_get_num_images(igm_disk());
            if (dir < 0 && s_disc_sel > 0)
               s_disc_sel--;
            else if (dir > 0 && s_disc_sel + 1 < num)
               s_disc_sel++;
         }
         break;
   }
}

enum spruce_igm_press spruce_igm_item_press(int id)
{
   switch (id)
   {
      case IGM_ID_FF_SPEED:
         return IGM_PRESS_NONE;
      case IGM_ID_SAVE:
         return IGM_PRESS_SAVE;
      case IGM_ID_UNDO_SAVE:
      case IGM_ID_SHOW_FPS:
      case IGM_ID_MUTE:
      case IGM_ID_REWIND:
      case IGM_ID_SHADER:
         return IGM_PRESS_STAY;
      default:
         return IGM_PRESS_CLOSE;
   }
}

static void igm_disc_insert(unsigned index)
{
   disk_control_interface_t *dc = igm_disk();

   if (index == disk_control_get_image_index(dc))
      return;
   if (!disk_control_get_eject_state(dc))
      disk_control_set_eject_state(dc, true, false);
   disk_control_set_index(dc, index, true);
   disk_control_set_eject_state(dc, false, false);
}

void spruce_igm_item_run(int id)
{
   settings_t *settings = config_get_ptr();

   switch (id)
   {
      case IGM_ID_LOAD:
         command_event(CMD_EVENT_LOAD_STATE, NULL);
         /* Loading while paused arms run_frames_and_pause, which would
          * re-pause after one frame. */
         runloop_state_get_ptr()->run_frames_and_pause = 0;
         break;
      case IGM_ID_UNDO_LOAD:
         command_event(CMD_EVENT_UNDO_LOAD_STATE, NULL);
         runloop_state_get_ptr()->run_frames_and_pause = 0;
         break;
      case IGM_ID_UNDO_SAVE:
         command_event(CMD_EVENT_UNDO_SAVE_STATE, NULL);
         break;
      case IGM_ID_RESET:
         command_event(CMD_EVENT_RESET, NULL);
         break;
      case IGM_ID_RETROARCH:
         command_event(CMD_EVENT_MENU_TOGGLE, NULL);
         break;
      case IGM_ID_EXIT:
         command_event(CMD_EVENT_QUIT, NULL);
         break;
      case IGM_ID_DISC:
         igm_disc_insert(s_disc_sel);
         break;
      case IGM_ID_SCREENSHOT:
         command_event(CMD_EVENT_TAKE_SCREENSHOT, NULL);
         break;
      case IGM_ID_SHOW_FPS:
         command_event(CMD_EVENT_FPS_TOGGLE, NULL);
         break;
      case IGM_ID_MUTE:
         command_event(CMD_EVENT_AUDIO_MUTE_TOGGLE, NULL);
         break;
      case IGM_ID_REWIND:
         configuration_set_bool(settings, settings->bools.rewind_enable,
               !settings->bools.rewind_enable);
         command_event(CMD_EVENT_REWIND_TOGGLE, NULL);
         break;
      case IGM_ID_SHADER:
#ifdef IGM_HAVE_SHADERS
         configuration_set_bool(settings, settings->bools.video_shader_enable,
               !settings->bools.video_shader_enable);
         video_shader_toggle(settings, true);
#endif
         break;
   }
}

static bool igm_toggle_state(int id)
{
   settings_t *settings = config_get_ptr();

   switch (id)
   {
      case IGM_ID_SHOW_FPS: return settings->bools.video_fps_show;
      case IGM_ID_MUTE:     return audio_state_get_ptr()->mute_enable;
      case IGM_ID_REWIND:   return settings->bools.rewind_enable;
      case IGM_ID_SHADER:   return settings->bools.video_shader_enable;
   }
   return false;
}

void spruce_igm_item_label(int id, const struct spruce_igm_theme *t,
      char *buf, size_t len)
{
   settings_t *settings = config_get_ptr();
   const char *label    = t->labels[id];

   switch (id)
   {
      case IGM_ID_SAVE:
      case IGM_ID_LOAD:
         {
            int slot = settings->ints.state_slot;
            if (slot < 0)
               snprintf(buf, len, "%s %s", label, t->auto_label);
            else
               snprintf(buf, len, "%s %s %d", label, t->slot_label, slot);
         }
         return;
      case IGM_ID_FF_SPEED:
         if (settings->floats.fastforward_ratio < 1.0f)
            snprintf(buf, len, "%s %s", label, t->max_label);
         else
            snprintf(buf, len, "%s %gx", label,
                  settings->floats.fastforward_ratio);
         return;
      case IGM_ID_DISC:
         snprintf(buf, len, "%s %u/%u", label, s_disc_sel + 1,
               disk_control_get_num_images(igm_disk()));
         return;
      case IGM_ID_SHOW_FPS:
      case IGM_ID_MUTE:
      case IGM_ID_REWIND:
      case IGM_ID_SHADER:
         snprintf(buf, len, "%s: %s", label,
               igm_toggle_state(id) ? t->on_label : t->off_label);
         return;
   }
   strlcpy(buf, label, len);
}

int spruce_igm_items_scroll(int selected, int count, int shown, int top)
{
   if (shown >= count)
      return 0;
   if (selected < top)
      top = selected;
   else if (selected >= top + shown)
      top = selected - shown + 1;
   if (top > count - shown)
      top = count - shown;
   if (top < 0)
      top = 0;
   return top;
}
