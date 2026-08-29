from asyncio import subprocess
from pathlib import Path
import time
from controller.controller_inputs import ControllerInput
from devices.device import Device
from devices.gkd.nm_wifi_scanner import WiFiNetwork
from devices.utils.process_runner import ProcessRunner
from display.display import Display
from display.on_screen_keyboard import OnScreenKeyboard
from utils.logger import PyUiLogger
from views.grid_or_list_entry import GridOrListEntry
from views.selection import Selection
from views.view_creator import ViewCreator
from views.view_type import ViewType

from menus.language.language import Language

class NmWifiMenu:
    def __init__(self):
        self.on_screen_keyboard = OnScreenKeyboard()

    def get_iface_name(self):
        res = "wlan0"
        interfaces = Path("/sys/class/net/")

        for i in interfaces.iterdir():
            if i.name.startswith("wlan"):
                res = i.name

        return res

    def wifi_adjust(self):
        if Device.get_device().is_wifi_enabled():
            Device.get_device().disable_wifi()
        else:
            Device.get_device().enable_wifi()

    def nm_connect(self, ssid: str, passwd: str):
        try:
            ProcessRunner.run(["nmcli", "device", "wifi", "connect", ssid, "password", passwd, "ifname", self._interface])
            PyUiLogger.get_logger().info(f"Connected to {ssid}.")
        except subprocess.CalledProcessError as e:
            PyUiLogger.get_logger().error(f"Error connecting to {ssid}: {e}")


    #TODO add confirmation or failed popups
    def switch_network(self, net: WiFiNetwork):
        PyUiLogger.get_logger().info(f"Selected {net.ssid}!")
        if(net.requires_password()):
            password = self.on_screen_keyboard.get_input("WiFi Password")
            if(password is not None and 8 <= len(password) <= 63):
                self.nm_connect(net.ssid, password)
                Display.display_message(f"Updating config file for {net.ssid} with password {password}", duration_ms=5000)
            else:
                Display.display_message("Invalid WiFi password length! Must be between 8 and 63", duration_ms=5000)

    def _build_options(
        self,
        wifi_enabled: bool,
        networks: list[WiFiNetwork],
        connected_ssid: str | None,
        connected_is_5ghz: bool,
    ):
        option_list = []

        # WiFi toggle entry
        option_list.append(
            GridOrListEntry(
                primary_text=Language.status(),
                value_text="<    " + ("On" if wifi_enabled else "Off") + "    >",
                image_path=None,
                image_path_selected=None,
                description=None,
                icon=None,
                value=self.wifi_adjust,
            )
        )

        # Network entries
        if wifi_enabled:
            if not networks:
                option_list.append(
                    GridOrListEntry(
                        primary_text="Scanning for networks...",
                        value_text=None,
                        image_path=None,
                        image_path_selected=None,
                        description=None,
                        icon=None,
                        value=lambda: None,
                    )
                )
            else:
                seen_names = set()
                for net in networks:
                    name = net.ssid
                    is_5ghz = 5000 <= net.frequency <= 6000

                    if is_5ghz:
                        name += " (5Ghz)"

                    if name in seen_names:
                        continue

                    seen_names.add(name)
                    connected = (
                        connected_ssid == net.ssid
                        and is_5ghz == connected_is_5ghz
                    )

                    option_list.append(
                        GridOrListEntry(
                            primary_text=name,
                            value_text="✓" if connected else None,
                            image_path=None,
                            image_path_selected=None,
                            description=None,
                            icon=None,
                            value=lambda net=net: self.switch_network(net),
                        )
                    )

        return option_list

    def adapter_is_connected(self):
        interfaces = Path("/sys/class/net/")

        for i in interfaces.iterdir():
            if i.name.startswith("eth") or i.name.startswith("wlan"):
                return True

        return False

    def show_wifi_menu(self):
        if self.adapter_is_connected():
            self._show_menu()
        else:
            message = "USB adapter not connected.\n" \
                    "Connect a compatible adapter to use WiFi.\n" \
                    "The device must be restarted to use WiFi after using sleep."
            Display.display_message(message, 5000)

    def _show_menu(self):
        selected = Selection(None, None, 0)
        self.wifi_scanner = Device.get_device().get_new_wifi_scanner()

        self._interface = self.get_iface_name()
        self.wifi_scanner.interface = self._interface

        # Start background scanning immediately
        self.wifi_scanner.scan_networks()

        connected_ssid = None
        connected_is_5ghz = False

        accepted_inputs = [
            ControllerInput.A,
            ControllerInput.DPAD_LEFT,
            ControllerInput.DPAD_RIGHT,
            ControllerInput.L1,
            ControllerInput.R1,
        ]

        try:
            while selected is not None:
                wifi_enabled = Device.get_device().is_wifi_enabled()

                # Pull latest scan snapshot (non-blocking)
                networks = (
                    self.wifi_scanner.scan_networks()
                    if wifi_enabled
                    else []
                )

                ssid, freq = self.wifi_scanner.get_connected_ssid()
                connected_ssid = ssid
                connected_is_5ghz = bool(freq and 5000 <= freq <= 6000)

                # Build options (single source of truth)
                option_list = self._build_options(
                    wifi_enabled=wifi_enabled,
                    networks=networks,
                    connected_ssid=connected_ssid,
                    connected_is_5ghz=connected_is_5ghz,
                )

                # Render view
                list_view = ViewCreator.create_view(
                    view_type=ViewType.ICON_AND_DESC,
                    top_bar_text="WiFi Configuration",
                    options=option_list,
                    selected_index=selected.get_index(),
                )

                # Single non-blocking poll
                selected = list_view.get_selection(accepted_inputs)

                if selected is None:
                    break

                if selected.get_input() in accepted_inputs:
                    selected.get_selection().value()
                elif ControllerInput.B == selected.get_input():
                    break

                # Prevent CPU spin
                time.sleep(0.05)

        finally:
            Display.display_message("Stopping WiFi scanner...")
            self.wifi_scanner.stop()
