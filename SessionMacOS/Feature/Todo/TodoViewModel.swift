//
//  NewTodoViewModel.swift
//  SessionMacOS
//
//  Created by Hilmy Veradin on 04/09/24.
//

import Foundation

enum TodoViewState {
    case category
    case todoInput
    case todoList
}

final class TodoViewModel: ObservableObject {
    @Published var todoInputText = ""
    @Published var viewState: TodoViewState = .todoList
    @Published var scrollTarget: Int?
    @Published var selectedCategory: Category?
    
    @Published var isTaggedInput = false
    
    @Published var filteredCategories: [Category] = []
    @Published var filteredSuggestedTodos: [Todo] = []
    
    @Published var categories: [Category] = []
    @Published var todos: [Todo] = []
    
    let keyEventHandler = KeyEventHandler()
    
    init() {
        loadData()
        setupKeyEventHandler()
    }
    
    func updateKeyEventHandlerItems() {
        keyEventHandler.updateItems(getRelevantItems())
    }
    
    private func loadData() {
        categories = DataManager.shared.loadCategories()
        todos = DataManager.shared.loadTodos()
        
        selectedCategory = categories.first
        
        filteredCategories = categories
        filteredSuggestedTodos = Array(todos.prefix(5)) // get first five todos as recommendation
    }
    
    private func setupKeyEventHandler() {
        keyEventHandler.onSelect = { [weak self] in self?.selectItem($0) }
        keyEventHandler.onScroll = { [weak self] index in
            self?.scrollTarget = index
        }
        keyEventHandler.updateItems(getRelevantItems())
    }
    
    func handleTextFieldChange(_ newValue: String) {
        /*
         1. Check if the string starts with @
         2. Check if the last character is @
         3. Check if @ exists somewhere in the middle
         4. If no @ exists, handle as regular input
         */
        
        if newValue.hasPrefix("@") {
            /*
             1. Remove the @ from the beginning
             2. Check if there's a space after @
             3. If space exists, reset to normal input mode
             4. If no space, filter categories based on text after @
             */
            let afterAt = String(newValue.dropFirst())
            if afterAt.contains(" ") {
                // Reset if there's a space after @
                isTaggedInput = false
                filterSuggestionTodos(newValue)
            } else {
                isTaggedInput = true
                filterCategories(afterAt)
            }
        } else if newValue.last == "@" {
            // If @ is the last character, enter tagged input mode
            isTaggedInput = true
            filteredCategories = categories
        } else if newValue.contains("@") {
            /*
             1. Split the string based on @, allowing only one split
             2. If split results in two components, process the part after @
             3. If there's a space after @, reset to normal input mode
             4. If no space after @, filter categories
             5. If split doesn't result in two components (e.g., multiple @), reset to normal input mode
             */
            let components = newValue.split(separator: "@", maxSplits: 1)
            if components.count == 2 {
                let afterAt = String(components[1])
                if afterAt.contains(" ") {
                    // Reset input and filtered suggested todos
                    isTaggedInput = false
                    filterSuggestionTodos(newValue)
                } else {
                    isTaggedInput = true
                    filterCategories(afterAt)
                }
            } else {
                // Handle case like "a@abade" or multiple @
                isTaggedInput = false
                filterSuggestionTodos(newValue)
            }
        } else {
            // No @ in the input, handle as regular input
            isTaggedInput = false
            filterSuggestionTodos(newValue)
        }
        
        updateKeyEventHandlerItems()
    }
    
    private func filterCategories(_ filter: String) {
        filteredCategories = categories.filter { category in
            category.name.lowercased().starts(with: filter.lowercased())
        }
    }

    private func filterSuggestionTodos(_ filter: String) {
        filteredSuggestedTodos = Array(todos.prefix(5)).filter { todo in
            todo.name.lowercased().starts(with: filter.lowercased())
        }
    }
    
    private func getRelevantItems() -> [Any] {
        if isTaggedInput {
            return filteredCategories
        }
        
        switch viewState {
        case .todoList: return todos
        case .category: return filteredCategories
        case .todoInput: return filteredSuggestedTodos
        }
    }
    
    func submitTodoTextfield(action: (() -> Void)? = nil) {
        guard let selectedCategory else { return }
        let todo = Todo(name: todoInputText, category: selectedCategory)
        selectItem(todo) {
            action?()
        }
    }
    
    func selectItem(_ item: Any, action: (() -> Void)? = nil) {
        switch viewState {
        case .category:
            guard let selectedCategoryItem = item as? Category else {return}
            selectedCategory = selectedCategoryItem
            viewState = .todoList
        case .todoInput:
            // Check if the input consists of category tag.
            // If yes, then process the category like on the top and remove the tagged text
            if isTaggedInput {
                guard let selectedCategoryItem = item as? Category else {return}
                selectedCategory = selectedCategoryItem
                filteredCategories = categories
                removeTagFromFocusText()
            } else {
                guard let newTodo = item as? Todo else { return }
                todos.insert(newTodo, at: 0)
                filteredSuggestedTodos = Array(todos.prefix(5))
                
                DataManager.shared.saveTodos(todos)
                viewState = .todoList
            }
            
        case .todoList:
            print("todo button clicked")
        }
        
        updateKeyEventHandlerItems()
        action?()
    }
    
    private func removeTagFromFocusText() {
        if let atIndex = todoInputText.firstIndex(of: "@") {
            todoInputText = String(todoInputText[..<atIndex]).trimmingCharacters(in: .whitespaces)
        }
    }
}
