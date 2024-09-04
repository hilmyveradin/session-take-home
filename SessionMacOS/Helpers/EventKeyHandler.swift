//
//  EventKeyHandler.swift
//  SessionMacOS
//
//  Created by Hilmy Veradin on 03/09/24.
//

import SwiftUI
import AppKit

class KeyEventHandler: ObservableObject {
    @Published var selectedIndex: Int = -1
    
    var items: [Any] = []
    var onSelect: ((Any) -> Void)?
    var onScroll: ((Int) -> Void)?
    
    private var monitor: Any?
    
    // Public Method
    func startMonitoring() {
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            self?.handleKeyEvent(event)
            return event
        }
    }
    
    func stopMonitoring() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    func updateItems(_ newItems: [Any]) {
        items = newItems
        selectedIndex = -1
    }
    
    // Private method
    private func handleKeyEvent(_ event: NSEvent) {
        switch event.keyCode {
        case 125: // Down arrow
            selectedIndex = min(selectedIndex + 1, items.count - 1)
            onScroll?(selectedIndex)
        case 126: // Up arrow
            selectedIndex = max(selectedIndex - 1, 0)
            onScroll?(selectedIndex)
        case 36: // Enter
            if selectedIndex >= 0 && selectedIndex < items.count {
                onSelect?(items[selectedIndex])
            }
        default:
            break
        }
    }
}

