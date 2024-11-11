import Foundation
import Quartz

var isMouseMode: Bool = false
var specialKeysHeldDown: Bool = false  // This will be true when Fn, Control, Option or Command are held down
var moveVector = CGPoint(x: 0, y: 0)
var scrollDir = CGPoint(x: 0, y: 0)
var realSpeed: CGFloat = 3  // Default speed
let directions: [Int: CGPoint] = [
    37: CGPoint(x: -1, y: 0),
    41: CGPoint(x: 0, y: 1),
    39: CGPoint(x: 0, y: -1),
    42: CGPoint(x: 1, y: 0),
]

var speedKeys: [Int] = []  // Array to track currently held down speed keys
var movementKeys: Set<Int> = []
var leftClickPressed = false
var rightClickPressed = false

// Updated modifier key callback to detect special key presses
func modifierKeyCallback(
    proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard type == .flagsChanged else { return Unmanaged.passUnretained(event) }

    let flags = event.flags
    let specialKeys: CGEventFlags = [.maskControl, .maskCommand, .maskAlternate, .maskSecondaryFn]

    // Check if any special keys are currently held down
    specialKeysHeldDown = flags.intersection(specialKeys).isEmpty == false

    if flags.contains(.maskAlphaShift) {
        isMouseMode = true
    } else {
        isMouseMode = false
    }

    return Unmanaged.passUnretained(event)
}

// Event handling for key press and release
func eventCallback(
    proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
    //var specialKeysPressed: Bool = false
    //if keyCode == 63 || keyCode == 59 || keyCode == 58 || keyCode == 55 || keyCode == 61 {  // Fn, Control, Left Option, Command, Right option
    //    specialKeysHeldDown = true
    //}

    if type == .keyDown {
        if isMouseMode && !specialKeysHeldDown {

            // Handle scrolling up (keycode 47: .)
            if keyCode == 47 {
                scrollDir.y = 1
            }

            // Handle scrolling down (keycode 43: ,)
            if keyCode == 43 {
                scrollDir.y = -1
            }

            // Adjust desired speed based on keys 0, 1, 2 // A, S, D
            if keyCode == 0 || keyCode == 1 || keyCode == 2 {
                if !speedKeys.contains(keyCode) {
                    speedKeys.append(keyCode)  // Add the key to the array of held speed keys
                }
            }

            // Update movement keys
            if directions.keys.contains(keyCode) {
                movementKeys.insert(keyCode)
            }

            // Handle left click (keycode 3)
            if keyCode == 3 && !leftClickPressed {
                leftClickPressed = true
                simulateLeftClickDown()
            }

            // Handle right click (keycode 5)
            if keyCode == 5 && !rightClickPressed {
                rightClickPressed = true
                simulateRightClickDown()
            }
            // All keys will be prevented if in mouse mode
            return nil
        }
    } else if type == .keyUp {
        if isMouseMode {
            // Remove key from the array when it's released
            if keyCode == 0 || keyCode == 1 || keyCode == 2 {
                speedKeys = speedKeys.filter { $0 != keyCode }
            }
            if keyCode == 47 {
                scrollDir.y = 0
            }

            // Handle scrolling down (keycode 43: ,)
            if keyCode == 43 {
                scrollDir.y = 0
            }
            if directions.keys.contains(keyCode) {
                movementKeys.remove(keyCode)
            }

            // Handle left click release (keycode 3)
            if keyCode == 3 && leftClickPressed {
                leftClickPressed = false
                simulateLeftClickUp()
            }

            // Handle right click release (keycode 5)
            if keyCode == 5 && rightClickPressed {
                rightClickPressed = false
                simulateRightClickUp()
            }
        }
    }

    return Unmanaged.passUnretained(event)  // Allow other keys
}

// Adjust desired speed based on the currently held speed keys
func adjustDesiredSpeed() {
    guard let lastKey = speedKeys.last else {
        realSpeed = 3  // Default speed if no speed keys are held
        return
    }
    // Set the speed based on the last pressed speed key
    switch lastKey {
    case 0:
        realSpeed = 1
    case 1:
        realSpeed = 5
    case 2:
        realSpeed = 7
    default:
        realSpeed = 3  // Default to 3 if no valid speed key pressed
    }
}

// Update movement vector based on current movement keys
func updateMoveVector() {
    var newMoveVector = CGPoint(x: 0, y: 0)

    for keyCode in movementKeys {
        if let direction = directions[keyCode] {
            newMoveVector.x += direction.x * realSpeed
            newMoveVector.y += direction.y * realSpeed
        }
    }

    moveVector = newMoveVector
}

var screenFrame = NSScreen.main?.frame ?? .zero  // Use var for dynamic updates

func updateScreenFrame() {
    screenFrame = NSScreen.main?.frame ?? .zero
}

// Register for screen change notifications, e.g., in your initialization code
NotificationCenter.default.addObserver(
    forName: NSApplication.didChangeScreenParametersNotification,
    object: nil,
    queue: .main
) { _ in
    updateScreenFrame()
}

func startMouseMovement() {
    Timer.scheduledTimer(withTimeInterval: 0.008, repeats: true) { _ in
        guard isMouseMode else { return }
        
        // Continuously adjust the speed every cycle
        adjustDesiredSpeed()
        updateMoveVector()
        
        let currentPosition = getCurrentMousePosition()
        
        // Calculate new position
        var newPosition = CGPoint(
            x: currentPosition.x + moveVector.x,
            y: currentPosition.y + moveVector.y
        )
        
        // Clamp to screen bounds
        newPosition.x = max(screenFrame.minX, min(newPosition.x, screenFrame.maxX - 1))
        newPosition.y = max(screenFrame.minY, min(newPosition.y, screenFrame.maxY - 1))
        
        // Create and post a mouse move event
        if let event = CGEvent(
            mouseEventSource: nil,
            mouseType: .mouseMoved,
            mouseCursorPosition: newPosition,
            mouseButton: .left
        ) {
            event.post(tap: .cghidEventTap)
        }
        
        // Scroll based on calculated direction and speed
        scrollMouse(
            xPixels: Int(scrollDir.x * realSpeed * 5),
            yPixels: Int(scrollDir.y * realSpeed * 5)
        )
    }
}


// Fetch current mouse position
func getCurrentMousePosition() -> CGPoint {
    return CGEvent(source: nil)?.location ?? .zero
}

// Simulate left mouse click down
func simulateLeftClickDown() {
    let point = getCurrentMousePosition()
    let mouseDown = CGEvent(
        mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point,
        mouseButton: .left)
    mouseDown?.post(tap: .cghidEventTap)
}

// Simulate left mouse click up
func simulateLeftClickUp() {
    let point = getCurrentMousePosition()
    let mouseUp = CGEvent(
        mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point,
        mouseButton: .left)
    mouseUp?.post(tap: .cghidEventTap)
}

// Simulate right mouse click down
func simulateRightClickDown() {
    let point = getCurrentMousePosition()
    let rightMouseDown = CGEvent(
        mouseEventSource: nil, mouseType: .rightMouseDown, mouseCursorPosition: point,
        mouseButton: .right)
    rightMouseDown?.post(tap: .cghidEventTap)
}

// Simulate right mouse click up
func simulateRightClickUp() {
    let point = getCurrentMousePosition()
    let rightMouseUp = CGEvent(
        mouseEventSource: nil, mouseType: .rightMouseUp, mouseCursorPosition: point,
        mouseButton: .right)
    rightMouseUp?.post(tap: .cghidEventTap)
}

func scrollMouse(xPixels: Int, yPixels: Int) {
    let scrollEvent = CGEvent(
        scrollWheelEvent2Source: nil,
        units: .pixel,  // Change to .pixel for precise scrolling by pixels
        wheelCount: 2,  // Two scroll wheels: vertical and horizontal
        wheel1: Int32(yPixels),  // Vertical scroll in pixels
        wheel2: Int32(xPixels),  // Horizontal scroll in pixels
        wheel3: 0  // Optional: use 0 if you don't need a third wheel
    )
    scrollEvent?.setIntegerValueField(.eventSourceUserData, value: 1)
    scrollEvent?.post(tap: .cghidEventTap)
}

// Start the event taps for both key events and modifier key events
let keyEventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
let modifierEventMask = (1 << CGEventType.flagsChanged.rawValue)
print("🚫🐁")
if let eventTap = CGEvent.tapCreate(
    tap: .cghidEventTap, place: .headInsertEventTap, options: .defaultTap,
    eventsOfInterest: CGEventMask(keyEventMask | modifierEventMask),
    callback: { proxy, type, event, refcon in
        modifierKeyCallback(proxy: proxy, type: type, event: event, refcon: refcon)
        return eventCallback(proxy: proxy, type: type, event: event, refcon: refcon)
    }, userInfo: nil)
{
    let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
    CGEvent.tapEnable(tap: eventTap, enable: true)
    startMouseMovement()
    CFRunLoopRun()
} else {
    print("Failed to create event tap.")
}
