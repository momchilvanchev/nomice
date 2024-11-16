# NoMouse: Revolutionizing How You Use Your Computer

NoMouse offers a unique, mouse-less way to navigate your Mac! Once you get the hang of it, you'll realize that keeping your hands on the keyboard can save you a lot of time (unless you're using a trackpad, in which case, it's probably more efficient to stick with it).

**Important**: NoMouse is **macOS-only** and is built using Swift with macOS-exclusive libraries for low-level control over the keyboard and cursor.

---

## Installation Guide

1. Copy the NoMouse.app folder into your Applications directory with the following command: `git clone https://github.com/momchilvanchev/nomice.git && cp -R nomice/NoMouse.app ~/Applications/`
2. Grant necessary permissions when prompted.
3. Optional but recommended: Run the following command to disable the Caps Lock indicator:
   `sudo defaults write /Library/Preferences/FeatureFlags/Domain/UIKit redesigned_text_cursor -dict-add Enabled -bool NO`
   **Then, restart your computer for changes to take place**.
4. Important: To stop NoMouse, open Activity Monitor, find the process 'nomouse' and quit it.

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
- A key - Slow speed
- S key - Normal speed
- D key - Fast speed
- F key - Left click | NOTE: Currently some actions like drag & drop don't work.
- G key - Right click
