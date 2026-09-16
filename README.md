# twigUI
spruceOS for the GKD Pixel 2

In addition to all spruceOS features, there's a handful of changes for this device:

- Shortcuts hotkey is the menu button instead of select (can be changed in the settings)
- MPV as a video player option (with hardware acceleration for H264/HEVC videos)
- Extra flycast versions
- D-pad to analog toggle in PPSSPP and ScummVM (L2 + R2)
- Mouse mode toggle in PICO-8 (L2 + R2)
  - L: left click
  - R: right click
- Option to turn off the screen while charging (enabled by default)
- zRam enabled by default
- Shutdown from sleep disabled by default (still can enable it)

#### USB Wifi

Only single function (no wifi+bluetooth) adapters that use the following chipsets work:
- RTL8188EU
- RTL8812AU
- RTL8814AU
- RTL8821AU
- RTL8821CU
- RTL8812BU
- RTL8822BU

Not all of them were tested, a confirmed to work adapter you can get for cheap is the TL-WN725N. Sleep disables the usb host driver so you need to restart to use wifi after using sleep.

## Known issues
- Charging with the device off doesn't work properly, please turn on the device to charge it.

## Installation

> [!CAUTION]
The installation process will wipe everything in your microSD card, make backups of any data you might want to preserve.

### Manual Installation
- Download [balenaEtcher](https://etcher.balena.io//#download-etcher)
- Download an install image from the [releases page](https://github.com/spruceUI/twigUI-next/releases) and extract the .img file.
- Remove the microSD card from your handheld and insert it into a microSD card reader.
- Run balenaEtcher, click on `Flash from file` and select the previously downloaded twigUI.img file.
- Click on `Select target` and select the microSD card previously inserted.
- Click on `Flash!` and wait for the process to finish.
- Once the flashing process is done remove the microSD card from the reader, insert it into your handheld and long press the power button to power it up.

## Updating

Easiest way to update is using the `Check for updates` App with a compatible USB wifi adapter. See other options below.

### EZ Updater

- Download the `twigUI_x.x.x_update.7z` file from the [latest release](https://github.com/spruceUI/twigUI-next/releases) in the releases page.
- Copy/paste this file directly onto the root of your microSD card (DO NOT EXTRACT THIS FILE).
- Turn on your device.
- Go to the "Apps" section and find the "EZ Updater" app and click on it.

It will go through the update process automatically! After it runs and a successful backup of your data it will update and shutdown your device. All you need to do is turn it back on and you're on the latest version.

### Manual

- Turn off your handheld and remove the microSD card
- Remove the microSD card from your handheld and insert it into a microSD card reader.
- Download an update image from the [releases page](https://github.com/spruceUI/twigUI-next/releases) and extract it.
- Open the `ROMS` partition (labeled as `twigUI` in windows) of your microSD card and remove everything except the following folders:
  - Roms
  - Saves
  - BIOS
  - Persistent
  - Collections
  - Themes
- Copy the extracted files from the update .7z file into the `ROMS`  partition (labeled as `twigUI` in windows) of the microSD card.
- When prompted, allow the new files to replace the existing ones.
- Once the copying process is done remove the microSD card from the reader, insert it into your handheld and long press the power button to power it up.

## Special thanks

- [The spruceOS team](https://github.com/spruceUI/spruceOS?tab=readme-ov-file#active-team-members)
- [ROCKNIX](https://github.com/ROCKNIX/distribution), this project is a ROCKNIX fork and wouldn't exist without it.
- [christianhaitian](https://github.com/christianhaitian) for some emulator [build scripts](https://github.com/christianhaitian/rk3326_core_builds).
- [RetroGFX](https://github.com/RetroGFX) for guidance setting up the build scripts and some patches from [UnofficialOS](https://github.com/RetroGFX/UnofficialOS).
