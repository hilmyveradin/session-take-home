//
//  TodoViewModel.swift
//  SessionMacOS
//
//  Created by Hilmy Veradin on 03/09/24.
//

import SwiftUI

class TodoViewModel: ObservableObject {
    @Published var focusText = ""
    @Published var selectedSession: Session?
    @Published var todoItems: [String] = []
    @Published var categoryItems: [String] = []
    @Published var colorItems: [String] = []
    @Published var focusItems: [String] = []
    @Published var filteredCategoryItems: [String] = []
    @Published var filteredFocusItems: [String] = []
    @Published var viewState: TodoViewState = .todo
    @Published var scrollTarget: Int?
    @Published var isTagIntention = false
    
    private var sessions: [Session] = []
    let keyEventHandler = KeyEventHandler()
    
    init() {
        loadData()
        setupKeyEventHandler()
    }
    
    private func loadData() {
        sessions = SessionDataManager.shared.loadSessions()
        selectedSession = sessions.first
        updateLists(with: selectedSession!)
    }
    
    private func setupKeyEventHandler() {
        keyEventHandler.onSelect = { [weak self] in self?.selectItem($0) }
        keyEventHandler.onScroll = { [weak self] index in
            self?.scrollTarget = index
        }
    }
    
    func updateKeyEventHandlerItems() {
        keyEventHandler.updateItems(getRelevantItems())
    }
    
    func handleTextFieldChange(_ newValue: String) {
        if newValue.last == "@" {
            isTagIntention = true
            filteredCategoryItems = categoryItems
        } else if newValue.contains("@") {
            let components = newValue.split(separator: "@")
            if components.count == 2 {
                let afterAt = String(components[1])
                if afterAt.contains(" ") {
                    isTagIntention = false
                    filteredFocusItems = focusItems
                } else {
                    isTagIntention = true
                    filterCategories(afterAt)
                }
            }
        } else {
            isTagIntention = false
            filterFocusItems(newValue)
        }
        updateKeyEventHandlerItems()
    }
    
    private func filterCategories(_ filter: String) {
        filteredCategoryItems = categoryItems.filter { $0.lowercased().starts(with: filter.lowercased()) }
    }
    
    private func filterFocusItems(_ filter: String) {
        filteredFocusItems = filter.isEmpty ? focusItems : focusItems.filter { $0.lowercased().contains(filter.lowercased()) }
    }
    
    private func getRelevantItems() -> [String] {
        if isTagIntention {
            return filteredCategoryItems
        }
        
        switch viewState {
        case .todo: return todoItems
        case .category: return filteredCategoryItems
        case .focus: return filteredFocusItems
        }
    }
    
    func selectItem(_ item: String, action: (() -> Void)? = nil) {
        switch viewState {
        case .todo:
            print("todo button clicked")
        case .category:
            if let session = sessions.first(where: { $0.name == item }) {
                selectedSession = session
                updateLists(with: session)
                viewState = .todo
                addFocusToSession()
            }
        case .focus:
            if isTagIntention {
                if let session = sessions.first(where: { $0.name == item }) {
                    selectedSession = session
                    updateLists(with: session)
                    viewState = .todo
                    addFocusToSession()
                }
            } else {
                
                addFocusToSession()
                viewState = .todo
                focusText = item
                
            }
        }
        updateKeyEventHandlerItems()
        action?()
    }
    
    private func updateLists(with session: Session) {
        todoItems = session.todo
        categoryItems = sessions.map { $0.name }
        focusItems = session.focus
        colorItems = sessions.map { $0.color }
        filteredCategoryItems = categoryItems
        filteredFocusItems = focusItems
    }
    
    private func addFocusToSession() {
        guard var updatedSession = selectedSession else { return }
        
        let newFocus = removeTagFromFocusText()
        if !newFocus.isEmpty && !updatedSession.focus.contains(newFocus) {
            updatedSession.focus.append(newFocus)
            selectedSession = updatedSession
            focusItems = updatedSession.focus
            filteredFocusItems = focusItems
            
            // Update the session in UserDefaults
            SessionDataManager.shared.updateSession(updatedSession)
        }
        
        focusText = ""
    }
    
    private func removeTagFromFocusText() -> String {
        if let atIndex = focusText.firstIndex(of: "@") {
            return String(focusText[..<atIndex]).trimmingCharacters(in: .whitespaces)
        }
        return focusText.trimmingCharacters(in: .whitespaces)
    }
}
