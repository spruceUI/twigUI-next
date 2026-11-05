#ifndef SPRUCE_IGM_THEME_H
#define SPRUCE_IGM_THEME_H

/*
 * Look and feel of the spruce in-game menu, loaded once per process from an
 * igm.json on the card.
 *
 * Read once, on the first menu open. A settings change therefore lands on the
 * next game launch, which is a new process. Nothing here is polled per frame.
 *
 * Missing keys keep their built-in default, so a colourway only has to list the
 * colours it cares about. A file that fails to parse is discarded whole and the
 * built-in look is used - the parse target is a scratch copy that is only
 * committed on success, so a truncated file can never leave a half-applied
 * theme on screen.
 *
 * Values are NOT range-checked. A theme that asks for a panel taller than the
 * screen gets one. This is deliberate.
 */

#include <stdint.h>
#include <boolean.h>
#include <retro_miscellaneous.h>   /* PATH_MAX_LENGTH */

#include "spruce_igm_items.h"

enum spruce_igm_color_id
{
   IGM_COL_DIM_BG = 0,
   IGM_COL_PANEL_BG,
   IGM_COL_SELECTION,
   IGM_COL_ACCENT,
   IGM_COL_TITLE_LINE,
   IGM_COL_TEXT,
   IGM_COL_TEXT_SELECTED,
   IGM_COL_TEXT_TITLE,
   IGM_COL_TEXT_SHADOW,
   IGM_COL_BATTERY,
   IGM_COL_COUNT
};

typedef struct spruce_igm_theme
{
   /* 0xRRGGBBAA - the form gfx_display_draw_text already takes, and the form
    * the JSON uses, so the common path converts nothing. */
   uint32_t rgba[IGM_COL_COUNT];

   /* Percentages of screen width or height. One file has to work from 640x480
    * up to 1280x720, so nothing here is in pixels except where a quantity is
    * genuinely absolute. */
   float margin_pct;
   float panel_w_pct;
   float item_h_pct;
   float title_h_pct;
   float panel_x_pct;             /* only meaningful when !panel_x_auto */
   float panel_y_pct;             /* only meaningful when !panel_y_auto */
   float separator_inset_pct;     /* of panel width */
   float arrow_inset_pct;         /* of panel width */
   float accent_w_pct;            /* of panel width, min 2px */
   float text_baseline;           /* fraction of a row's height */
   float title_baseline;          /* fraction of the title row's height */
   float scale;                   /* multiplies the above, on top of the
                                     per-device IGM_LAYOUT_SCALE */

   int   separator_h_px;
   int   shadow_offset_px;

   bool  panel_x_auto;            /* x = margin */
   bool  panel_y_auto;            /* vertically centred */
   bool  accent_bar;
   bool  shadow;
   bool  show_battery;
   bool  show_preview;

   float font_size_pct;
   float font_size_small_pct;
   float font_battery_size_pct;   /* drives the battery baseline offset */
   char  font_path[PATH_MAX_LENGTH];

   char  title[64];
   char  labels[IGM_ID_COUNT][48];
   char  auto_label[24];
   char  slot_label[24];
   char  max_label[24];
   char  on_label[24];
   char  off_label[24];
   char  arrow_left[8];
   char  arrow_right[8];

   char  source_path[PATH_MAX_LENGTH];   /* "" when nothing was loaded */
} spruce_igm_theme_t;

/* Loads on the first call, then hands back the same pointer. Never NULL. */
const spruce_igm_theme_t *spruce_igm_theme_get(void);

/* Forces a re-read. Nothing calls this today; it exists so a future
 * reload-without-relaunch does not have to reach into the statics. */
void spruce_igm_theme_reload(void);

/* One canonical store, three consumers: RGBA words for the GPU text path,
 * ARGB words for the Miyoo Mini's software blitter, and a four-vertex float
 * quad for gfx_display_draw_quad - which COLOR_HEX_TO_FLOAT cannot produce at
 * runtime, being a brace initialiser. */
uint32_t spruce_igm_theme_color_rgba(const spruce_igm_theme_t *t, int id);
uint32_t spruce_igm_theme_color_argb(const spruce_igm_theme_t *t, int id);
void     spruce_igm_theme_color_float(const spruce_igm_theme_t *t, int id,
      float out[16]);

#endif /* SPRUCE_IGM_THEME_H */
