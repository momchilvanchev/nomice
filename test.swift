import Foundation
import Quartz

public func scrollMouse(onPoint point: CGPoint, xLines: Int, yLines: Int) {
    if #available(macOS 10.13, *) {
        guard
            let scrollEvent = CGEvent(
                scrollWheelEvent2Source: nil,
                units: .line,
                wheelCount: 2,
                wheel1: Int32(yLines),
                wheel2: Int32(xLines),
                wheel3: 0
            )
        else {
            return
        }
        scrollEvent.setIntegerValueField(.eventSourceUserData, value: 1)
        scrollEvent.post(tap: .cghidEventTap)
    } else {
        print("Scrolling not supported on macOS older than 10.13")
    }
}

// Example usage
scrollMouse(onPoint: CGPoint(x: 0, y: 0), xLines: 0, yLines: 3)  // Scrolls up by 3 lines
//scrollMouse(onPoint: CGPoint(x: 0, y: 0), xLines: 0, yLines: -3)  // Scrolls down by 3 lines
