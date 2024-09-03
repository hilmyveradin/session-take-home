//
//  TodoViewModel.swift
//  SessionMacOS
//
//  Created by Hilmy Veradin on 03/09/24.
//

import SwiftUI

// MARK: - ViewModel
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
    
    private var mockSessionData: [Session] = []
    let keyEventHandler = KeyEventHandler()
    
    init() {
        loadMockData()
        setupKeyEventHandler()
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
    
    func selectItem(_ item: String) {
        switch viewState {
        case .todo:
            print("todo button clicked")
        case .category:
            if let session = mockSessionData.first(where: { $0.name == item }) {
                selectedSession = session
                updateLists(with: session)
                viewState = .todo
                removeTagFromFocusText()
            }
        case .focus:
            if isTagIntention {
                if let session = mockSessionData.first(where: { $0.name == item }) {
                    selectedSession = session
                    updateLists(with: session)
                    viewState = .todo
                    removeTagFromFocusText()
                }
            } else {
                focusText = item
            }
            viewState = .todo
        }
        updateKeyEventHandlerItems()
    }
    
    private func updateLists(with session: Session) {
        todoItems = session.list
        categoryItems = mockSessionData.map { $0.name }
        focusItems = session.focus
        colorItems = mockSessionData.map { $0.color }
        filteredCategoryItems = categoryItems
        filteredFocusItems = focusItems
    }
    
    private func removeTagFromFocusText() {
        if let atIndex = focusText.firstIndex(of: "@") {
            focusText = String(focusText[..<atIndex]).trimmingCharacters(in: .whitespaces)
        }
    }
    
    private func loadMockData() {
        guard let url = Bundle.main.url(forResource: "MockData", withExtension: "json") else {
            print("MockData.json not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            mockSessionData = try decoder.decode([Session].self, from: data)
            
            selectedSession = mockSessionData.first
            updateLists(with: selectedSession!)
        } catch {
            print("Error decoding MockData.json: \(error)")
        }
    }
}
