#!/usr/bin/env python3

from subprocess import PIPE, run

from devices.device import Device
from display.display import Display
from controller.controller import Controller
from controller.controller_inputs import ControllerInput

def prompt_user(text: str) -> bool:
    while(True):
        Display.display_message(text, 1)

        if(Controller.get_input()):
            if(Controller.last_input() == ControllerInput.A):
                return True
            if(Controller.last_input() == ControllerInput.B):
                break

    return False

def main() -> None:
    cmd_result = run(["gpudriver"], stdout=PIPE, universal_newlines=True)
    curr_driver = cmd_result.stdout.strip()

    text_append = ""

    match curr_driver:
        case "libmali":
            new_driver = "panfrost"
            text_append = "Panfrost can cause visual glitches in the main menu, only use if it's required by any port.\n\n"
        case "panfrost":
            new_driver = "libmali"
        case _:
            pass

    res = prompt_user(f"{text_append}Switch from {curr_driver} to {new_driver}?\nThe device needs to restart to switch GPU drivers.\n\nA = Accept, B = Cancel")

    if res:
        run(["gpudriver", new_driver])
        Device.get_device().reboot()

if __name__ == "__main__":
    main()
