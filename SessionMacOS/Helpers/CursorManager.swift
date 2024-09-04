//
//  CursorManager.swift
//  SessionMacOS
//
//  Created by Hilmy Veradin on 05/09/24.
//

import AppKit

class CursorManager {
    static let shared = CursorManager()
    
    private var isHidden = false
    private var mouseMovementMonitor: Any?
    
    private init() {}
    
    var isCursorShown: Bool {
        return !isHidden
    }
    
    func hideCursor() {
        if !isHidden {
            NSCursor.hide()
            isHidden = true
            startMonitoringMouseMovement()
        }
    }
    
    private func showCursor() {
        if isHidden {
            NSCursor.unhide()
            isHidden = false
            stopMonitoringMouseMovement()
        }
    }
    
    private func startMonitoringMouseMovement() {
        mouseMovementMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { event in
            DispatchQueue.main.async {
                self.showCursor()
            }
            return event
        }
    }
    
    private func stopMonitoringMouseMovement() {
        if let monitor = mouseMovementMonitor {
            NSEvent.removeMonitor(monitor)
            mouseMovementMonitor = nil
        }
    }
}
