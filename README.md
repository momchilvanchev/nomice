# NoMouse: Revolutionizing How You Use Your Computer

NoMouse offers a unique, mouse-less way to navigate your Mac! Once you get the hang of it, you'll realize that keeping your hands on the keyboard can save you a lot of time (unless you're using a trackpad, in which case, it's probably more efficient to stick with it).

**Important**: NoMouse is **macOS-only** and is built using Swift with macOS-exclusive libraries for low-level control over the keyboard and cursor.

Note: It is recommended to use NoMouse on MacOS Venture (v13) and above! NoMouse is not guaranteed to work on earlier versions of MacOS.

---

## Installation Guide

### Install using Zip:

1. Download the zip file, unzip it and place the NoMouse app in your /Applications directory.

### OR Install using git:

1. Copy the NoMouse.app folder into your Applications directory with the following command: `git clone https://github.com/momchilvanchev/nomice.git && sudo cp -R nomice/NoMouse.app /Applications/ && rm -rf nomice`

#### **_Then_**:

2. Grant necessary permissions when prompted.
3. Optional but recommended: Run the following command to disable the Caps Lock indicator:
   `sudo defaults write /Library/Preferences/FeatureFlags/Domain/UIKit redesigned_text_cursor -dict-add Enabled -bool NO`
   **Then, restart your computer for changes to take place**.
4. You may get a _“NoMouse” cannot be opened because it is from an unidentified developer._ error. Just go to Settings, then Privacy & Security, scroll down till you find something like _“NoMouse” was blocked from use because it is not from an identidied developer._ Click _Open Anyway_ and you should be good to go :)

---

## How to use NoMouse:

- CapsLock - Toggle Mouse mode on and off
- \ key - Move right
- ' key - Move up
- ; key - Move down
- L key - Move left
  ( Combination between L ; ' \ will result in diagonals or canceling out )
- , key - Scroll down
- . key - Scroll up
- O key - Scroll left
- P key - Scroll right
- A key - Slow speed
- S key - Normal speed
- D key - Fast speed
- F key - Left click | NOTE: Currently some actions like drag & drop don't work.
- G key - Right click
