#ifndef SPRUCE_IGM_PLATFORM_H
#define SPRUCE_IGM_PLATFORM_H

/*
 * Everything that differs between the GPU IGM builds.
 *
 * spruce_igm.c is identical across the common, pixel2 and rgds patches; the
 * build script selects a variant with -DIGM_VARIANT_PIXEL2 or -DIGM_VARIANT_RGDS
 * and common is the default.
 *
 * IGM_LAYOUT_SCALE is a double and IGM_FONT_SCALE a float only because that is
 * what the pixel2/rgds sources used. They agree on every value these builds
 * actually produce - the types are kept apart to mirror the original, not to
 * dodge a rounding difference.
 */

#if defined(IGM_VARIANT_RGDS)
#  ifndef IGM_BASE_DIR
#    define IGM_BASE_DIR      "/storage/RetroArch"
#  endif
#  ifndef IGM_FONT_PRIMARY
#    define IGM_FONT_PRIMARY  "/storage/RetroArch/nunwen.ttf"
#  endif
#  ifndef IGM_FONT_FALLBACK
#    define IGM_FONT_FALLBACK "/storage/RetroArch/nunwen.ttf"
#  endif
#  ifndef IGM_LAYOUT_SCALE
#    define IGM_LAYOUT_SCALE  1.2
#  endif
#  ifndef IGM_FONT_SCALE
#    define IGM_FONT_SCALE    1.2f
#  endif
#  ifndef IGM_BATTERY_SMALL
#    define IGM_BATTERY_SMALL 0
#  endif
#elif defined(IGM_VARIANT_PIXEL2)
#  ifndef IGM_BASE_DIR
#    define IGM_BASE_DIR      "/mnt/SDCARD/RetroArch"
#  endif
#  ifndef IGM_FONT_PRIMARY
#    define IGM_FONT_PRIMARY  "/mnt/SDCARD/Themes/SPRUCE/nunwen.ttf"
#  endif
#  ifndef IGM_FONT_FALLBACK
#    define IGM_FONT_FALLBACK "/mnt/SDCARD/App/PixelReader/resources/fonts/nunwen.ttf"
#  endif
#  ifndef IGM_LAYOUT_SCALE
#    define IGM_LAYOUT_SCALE  1.2
#  endif
#  ifndef IGM_FONT_SCALE
#    define IGM_FONT_SCALE    1.2f
#  endif
#  ifndef IGM_BATTERY_SMALL
#    define IGM_BATTERY_SMALL 0
#  endif
#else
#  ifndef IGM_BASE_DIR
#    define IGM_BASE_DIR      "/mnt/SDCARD/RetroArch"
#  endif
#  ifndef IGM_FONT_PRIMARY
#    define IGM_FONT_PRIMARY  "/mnt/SDCARD/Themes/SPRUCE/nunwen.ttf"
#  endif
#  ifndef IGM_FONT_FALLBACK
#    define IGM_FONT_FALLBACK "/mnt/SDCARD/App/PixelReader/resources/fonts/nunwen.ttf"
#  endif
#  ifndef IGM_LAYOUT_SCALE
#    define IGM_LAYOUT_SCALE  1.0
#  endif
#  ifndef IGM_FONT_SCALE
#    define IGM_FONT_SCALE    1.0f
#  endif
#  ifndef IGM_BATTERY_SMALL
#    define IGM_BATTERY_SMALL 1
#  endif
#endif

#ifndef IGM_FLAG_PATH
#  define IGM_FLAG_PATH IGM_BASE_DIR "/IGM.txt"
#endif

#endif /* SPRUCE_IGM_PLATFORM_H */
