import Foundation
import SwiftUI

enum TodoViewState {
    case category
    case todoInput
    case todoList
}

enum TodoViewFocusState {
    case categoryList
    case todoSuggestedList
    case todoInputList
    case todoList
}

@MainActor
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
    @Published var selectedItemIndex = -1
    
    @Published var todoAlertMessage = ""
    
    // View Bindings
    var isShowTodoAlertBinding: Binding<Bool> {
        Binding(
            get: { self.isShowTodoAlert },
            set: { newValue in self.isShowTodoAlert = newValue }
        )
    }
    
    private var isShowTodoAlert = false
    
    private var currentItems: [Any] {
        getRelevantItems()
    }
    
    private enum MoveDirection {
        case up, down
    }
    
    init() {
        loadData()
    }
    
    func resetStates() {
        selectedItemIndex = -1
        
    }
    
    func handleTextFieldChange(_ newValue: String) {
        if newValue.hasPrefix("@") {
            let afterAt = String(newValue.dropFirst())
            if afterAt.contains(" ") {
                isTaggedInput = false
                selectedItemIndex = -1
                filterSuggestionTodos(newValue)
            } else {
                isTaggedInput = true
                selectedItemIndex = 0
                filterCategories(afterAt)
            }
        } else if newValue.last == "@" {
            isTaggedInput = true
            selectedItemIndex = 0
            filteredCategories = categories
        } else if newValue.contains("@") {
            let components = newValue.split(separator: "@", maxSplits: 1)
            if components.count == 2 {
                let afterAt = String(components[1])
                if afterAt.contains(" ") {
                    isTaggedInput = false
                    selectedItemIndex = -1
                    filterSuggestionTodos(newValue)
                } else {
                    isTaggedInput = true
                    selectedItemIndex += 1
                    filterCategories(afterAt)
                }
            } else {
                isTaggedInput = false
                selectedItemIndex = -1
                filterSuggestionTodos(newValue)
            }
        } else {
            isTaggedInput = false
            filterSuggestionTodos(newValue)
        }
    }
    
    func handleKeyPress(_ keyPress: KeyPress, isTextfieldState: Bool? = nil) -> KeyPress.Result {
        switch keyPress.key {
        case .upArrow:
            deferredMoveSelection(direction: .up)
            return .handled
        case .downArrow:
            deferredMoveSelection(direction: .down)
            return .handled
        case .return:
            return deferredHandleReturnKey()
        default:
            return .ignored
        }
    }
    
    func resetTodoAlert() {
        Task { @MainActor in
            todoAlertMessage = ""
            isShowTodoAlert = false
        }

    }
    private func deferredMoveSelection(direction: MoveDirection) {
        Task { @MainActor in
            switch direction {
            case .up:
                selectedItemIndex = max(selectedItemIndex - 1, 0)
            case .down:
                selectedItemIndex = min(selectedItemIndex + 1, currentItems.count - 1)
            }
            scrollTarget = selectedItemIndex
        }
    }
    
    private func deferredHandleReturnKey() -> KeyPress.Result {
        Task { @MainActor in
            
            if viewState == .todoInput && todoInputText != "" {
                self.submitTodoTextfield()
            }
            
            if selectedItemIndex >= 0 && selectedItemIndex < currentItems.count {
                selectItem(currentItems[selectedItemIndex])
            }
            
            selectedItemIndex = -1
            scrollTarget = 0
        }
        return .handled
    }


    private func loadData() {
        categories = DataManager.shared.loadCategories()
        todos = DataManager.shared.loadTodos()
        selectedCategory = categories.first
        filteredCategories = categories
        filteredSuggestedTodos = Array(todos.prefix(5))
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
        selectItem(todo)
        action?()
    }
    
    func selectItem(_ item: Any, action: (() -> Void)? = nil) {
        switch viewState {
        case .category:
            if let selectedCategoryItem = item as? Category {
                selectedCategory = selectedCategoryItem
                viewState = .todoList
            }
        case .todoInput:
            if isTaggedInput && selectedItemIndex >= 0 {
                if let selectedCategoryItem = item as? Category {
                    selectedCategory = selectedCategoryItem
                    filteredCategories = categories
                    removeTagFromFocusText()
                }
            } else {
                if let newTodo = item as? Todo {
                    if let existingIndex = todos.firstIndex(where: { $0.id == newTodo.id }) {
                        let existingTodo = todos.remove(at: existingIndex)
                        todos.insert(existingTodo, at: 0)
                    } else {
                        todos.insert(newTodo, at: 0)
                    }
                    todoInputText = newTodo.name
                    filteredSuggestedTodos = Array(todos.prefix(5))
                    DataManager.shared.saveTodos(todos)
                    viewState = .todoList
                }
            }
        case .todoList:
            if let newTodo = item as? Todo {
                isShowTodoAlert = true
                todoAlertMessage = newTodo.name
            }
            
        }
        action?()
    }
    
    private func removeTagFromFocusText() {
        if let atIndex = todoInputText.firstIndex(of: "@") {
            todoInputText = String(todoInputText[..<atIndex]).trimmingCharacters(in: .whitespaces)
        }
    }
}
