This project delivers a new way of using your computor. A mouse-less way! Once you get the hang of it, you will see, that keeping your hands on your keyboard saves a lot of time ( unless you use a trackpad, in which case, it's probably more efficient to use the trackpad ).

NoMouse is for MacOS ONLY! It is made in Swift with MacOS exclusive libraries for low-level control over the keyboard and cursor.

How to install:

Just copy NoMouse.app folder into Applications.
Grant permissions if prompted.
Optional, but recommended: Run `sudo defaults write /Library/Preferences/FeatureFlags/Domain/UIKit redesigned_text_cursor -dict-add Enabled -bool NO` to disable caps lock indicator and then restart your computer.

---

How to use NoMouse:

CapsLock - Toggle Mouse mode on and off
\ key - Move right
' key - Move up
; key - Move down
L key - Move left
( Combination between L ; ' \ will result in diagonals or canceling out )
, key - Scroll down
. key - Scroll up
A key - Slow speed
S key - Normal speed
D key - Fast speed
F key - Left click | NOTE: Currently some actions like drag & drop don't work.
G key - Right click

NoMouse now may seem complicated and too hard to even bother, but trust me, if you're currently on a seperate keyboard and mouse setup, taking the time ( usually a few hours ) to get used to NoMouse is definitely worth it.
