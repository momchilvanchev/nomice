import Cocoa
import Foundation
import Quartz

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        // Set the menu bar icon
        if let button = statusItem?.button {
            button.image = NSImage(
                systemSymbolName: "cursorarrow.motionlines", accessibilityDescription: "NoMouse")
        }

        // Add a menu to the item
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit NoMouse", action: #selector(quit), keyEquivalent: "q"))
        statusItem?.menu = menu
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}

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

func modifierKeyCallback(
    proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard type == .flagsChanged else { return Unmanaged.passUnretained(event) }

    let flags = event.flags
    let specialKeys: CGEventFlags = [
        .maskControl, .maskCommand, .maskAlternate, .maskSecondaryFn, .maskShift,
    ]

    specialKeysHeldDown = flags.intersection(specialKeys).isEmpty == false

    if flags.contains(.maskAlphaShift) {
        isMouseMode = true
    } else {
        isMouseMode = false
    }

    return Unmanaged.passUnretained(event)
}

func eventCallback(
    proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))

    if type == .keyDown {
        if isMouseMode && !specialKeysHeldDown {
            if keyCode == 47 { scrollDir.y = 1 }
            if keyCode == 43 { scrollDir.y = -1 }
            if keyCode == 31 { scrollDir.x = -1 }
            if keyCode == 35 { scrollDir.x = 1 }
            if keyCode == 0 || keyCode == 1 || keyCode == 2 {
                if !speedKeys.contains(keyCode) { speedKeys.append(keyCode) }
            }
            if directions.keys.contains(keyCode) { movementKeys.insert(keyCode) }
            if keyCode == 3 && !leftClickPressed {
                leftClickPressed = true
                simulateLeftClickDown()
            }
            if keyCode == 5 && !rightClickPressed {
                rightClickPressed = true
                simulateRightClickDown()
            }
            return nil
        }
    } else if type == .keyUp {
        if isMouseMode {
            if keyCode == 0 || keyCode == 1 || keyCode == 2 {
                speedKeys = speedKeys.filter { $0 != keyCode }
            }
            if keyCode == 47 { scrollDir.y = 0 }
            if keyCode == 43 { scrollDir.y = 0 }
            if keyCode == 31 { scrollDir.x = 0 }
            if keyCode == 35 { scrollDir.x = 0 }
            if directions.keys.contains(keyCode) { movementKeys.remove(keyCode) }
            if keyCode == 3 && leftClickPressed {
                leftClickPressed = false
                simulateLeftClickUp()
            }
            if keyCode == 5 && rightClickPressed {
                rightClickPressed = false
                simulateRightClickUp()
            }
        }
    }
    return Unmanaged.passUnretained(event)
}

func adjustDesiredSpeed() {
    guard let lastKey = speedKeys.last else {
        realSpeed = 3
        return
    }
    switch lastKey {
    case 0: realSpeed = 1
    case 1: realSpeed = 5
    case 2: realSpeed = 8
    default: realSpeed = 3
    }
}

func simulateMouseDrag(startPoint: CGPoint, endPoint: CGPoint) {
    let mouseDown = CGEvent(
        mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: startPoint,
        mouseButton: .left)
    mouseDown?.post(tap: .cghidEventTap)

    var currentPos = startPoint
    let numberOfSteps = 10
    let deltaX = (endPoint.x - startPoint.x) / CGFloat(numberOfSteps)
    let deltaY = (endPoint.y - startPoint.y) / CGFloat(numberOfSteps)

    for _ in 1...numberOfSteps {
        currentPos.x += deltaX
        currentPos.y += deltaY
        let mouseMove = CGEvent(
            mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: currentPos,
            mouseButton: .left)
        mouseMove?.post(tap: .cghidEventTap)
        usleep(10000)
    }

    let mouseUp = CGEvent(
        mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: currentPos,
        mouseButton: .left)
    mouseUp?.post(tap: .cghidEventTap)
}

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

var screenFrame = NSScreen.main?.frame ?? .zero

func updateScreenFrame() {
    screenFrame = NSScreen.main?.frame ?? .zero
}

NotificationCenter.default.addObserver(
    forName: NSApplication.didChangeScreenParametersNotification,
    object: nil,
    queue: .main
) { _ in updateScreenFrame() }

func startMouseMovement() {
    Timer.scheduledTimer(withTimeInterval: 0.008, repeats: true) { _ in
        guard isMouseMode else { return }
        adjustDesiredSpeed()
        updateMoveVector()
        let currentPosition = getCurrentMousePosition()
        var newPosition = CGPoint(
            x: currentPosition.x + moveVector.x,
            y: currentPosition.y + moveVector.y)
        newPosition.x = max(screenFrame.minX, min(newPosition.x, screenFrame.maxX - 1))
        newPosition.y = max(screenFrame.minY, min(newPosition.y, screenFrame.maxY - 1))
        if let event = CGEvent(
            mouseEventSource: nil,
            mouseType: .mouseMoved,
            mouseCursorPosition: newPosition,
            mouseButton: .left)
        {
            event.post(tap: .cghidEventTap)
        }
        scrollMouse(
            xPixels: Int(scrollDir.x * realSpeed * 4),
            yPixels: Int(scrollDir.y * realSpeed * 4))
    }
}

func getCurrentMousePosition() -> CGPoint {
    return CGEvent(source: nil)?.location ?? .zero
}

func simulateLeftClickDown() {
    let point = getCurrentMousePosition()
    let mouseDown = CGEvent(
        mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point,
        mouseButton: .left)
    mouseDown?.post(tap: .cghidEventTap)
}

func simulateLeftClickUp() {
    let point = getCurrentMousePosition()
    let mouseUp = CGEvent(
        mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point,
        mouseButton: .left)
    mouseUp?.post(tap: .cghidEventTap)
}

func simulateRightClickDown() {
    let point = getCurrentMousePosition()
    let rightMouseDown = CGEvent(
        mouseEventSource: nil, mouseType: .rightMouseDown, mouseCursorPosition: point,
        mouseButton: .right)
    rightMouseDown?.post(tap: .cghidEventTap)
}

func simulateRightClickUp() {
    let point = getCurrentMousePosition()
    let rightMouseUp = CGEvent(
        mouseEventSource: nil, mouseType: .rightMouseUp, mouseCursorPosition: point,
        mouseButton: .right)
    rightMouseUp?.post(tap: .cghidEventTap)
}

func scrollMouse(xPixels: Int, yPixels: Int) {
    let scrollEvent = CGEvent(
        scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 2, wheel1: Int32(yPixels),
        wheel2: Int32(xPixels),
        wheel3: 0)
    scrollEvent?.post(tap: .cghidEventTap)
}

let eventMask = CGEventMask(
    (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue))
let modifierMask = CGEventMask(1 << CGEventType.flagsChanged.rawValue)

let modifierKeyTap = CGEvent.tapCreate(
    tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap,
    eventsOfInterest: modifierMask, callback: modifierKeyCallback, userInfo: nil)

let keyTap = CGEvent.tapCreate(
    tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap,
    eventsOfInterest: eventMask,
    callback: eventCallback, userInfo: nil)

let runLoopSourceModifierTap = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, modifierKeyTap, 0)
let runLoopSourceKeyTap = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, keyTap, 0)

CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSourceModifierTap, .commonModes)
CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSourceKeyTap, .commonModes)

startMouseMovement()
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
