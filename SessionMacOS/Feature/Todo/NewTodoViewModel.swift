//
//  NewTodoViewModel.swift
//  SessionMacOS
//
//  Created by Hilmy Veradin on 04/09/24.
//

import Foundation

enum NewTodoViewState {
    case category
    case todoInput
    case todoList
}

final class NewTodoViewModel: ObservableObject {
    @Published var todoInputText = ""
    @Published var viewState: NewTodoViewState = .todoList
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
         1. Check if the last value consists of @
         2. Check if the value contains @. This to ensure the behaviour of @ exists but not in the last element
         3. If the @ doesn't exists, do as regular
         */
        if newValue.last == "@" {
            isTaggedInput = true
            filteredCategories = categories
        } else if newValue.contains("@") {
            /*
             1. Separate component based on the @ syntax. he result should be two different sets of strings
             2. If the count is not a pair of string subsequesce, return it
             3. Check if the afterAt contains empty space, if there's an empty space then make the add act like a default string input. If not then continue to filter the categories
             */
            let components = newValue.split(separator: "@")
            guard components.count == 2 else { return }
            let afterAt = String(components[1])
            
            if afterAt.contains(" ") {
                // Reset input and filtered suggested todos
                isTaggedInput = false
                filteredSuggestedTodos = Array(todos.prefix(5))
            } else {
                isTaggedInput = true
                filterCategories(afterAt)
            }
            
        } else {
            
        }
    }
    
    private func filterCategories(_ filter: String) {
        filteredCategories = categories.filter { category in
            category.name.lowercased().starts(with: filter.lowercased())
        }
    }

    private func filterSuggestionTodos(_ filter: String) {
        filteredSuggestedTodos = todos.filter { todo in
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
                removeTagFromFocusText()
                
            } else {
                updateTodoList()
                viewState = .todoList
            }
            
        case .todoList:
            print("todo button clicked")
        }
        
        action?()
    }
    
    private func updateTodoList() {
        guard let selectedCategory else { return }
        let newTodo = Todo(name: todoInputText, category: selectedCategory)
        
        todos.insert(newTodo, at: 0)
        filteredSuggestedTodos = Array(todos.prefix(5))
        
        DataManager.shared.updateTodo(newTodo)
    }
    
    private func removeTagFromFocusText() {
        if let atIndex = todoInputText.firstIndex(of: "@") {
            todoInputText = String(todoInputText[..<atIndex]).trimmingCharacters(in: .whitespaces)
        }
    }
}
