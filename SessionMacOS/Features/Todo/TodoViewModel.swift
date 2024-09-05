//
//  TodoViewModel.swift
//  SessionMacOS
//
//  Created by Hilmy Veradin on 04/09/24.
//

import AppKit
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
    private enum MoveDirection {
        case up, down
    }

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

    @Published var selectedTodoUidSet: Set<String> = []

    @Published var isJustSubmittedTodo = false

    var selectedCategoryName: String {
        selectedCategory?.name.capitalized ?? "No Category Found"
    }

    var isRegularTextfield: Bool {
        filteredCategories.count == 0 || !isTaggedInput
    }

    private var currentItems: [Any] {
        getRelevantItems()
    }

    private var isJustSubmitTodo = false

    // MARK: - INIT

    init() {
        loadData()
    }

    // MARK: - PUBLIC METHODS

    func onAppear(viewFocus: Binding<TodoViewState?>) {
        viewFocus.wrappedValue = viewState
    }

    func onFocusChange(newValue: TodoViewState?) {
        viewState = newValue ?? .todoList
        selectedItemIndex = -1
    }

    func onViewStateChange(newValue: TodoViewState, viewFocus: Binding<TodoViewState?>) {
        viewFocus.wrappedValue = newValue
        selectedItemIndex = -1
    }

    func isItemViewHovered(index: Int, currentState: TodoViewState) -> Bool {
        switch currentState {
        case .category:
            let isSelected = index == selectedItemIndex
            let isHovered = isSelected && viewState == .category
            return isHovered
        case .todoInput:
            let isSelected = index == selectedItemIndex
            let isHovered = isSelected && viewState == .todoInput
            return isHovered
        case .todoList:
            let isSelected = index == selectedItemIndex
            let isHovered = isSelected && viewState == .todoList
            return isHovered
        }
    }

    func onCategoryHeaderTap() {
        viewState = .category
    }

    func onTodoItemHover(hovering: Bool, index: Int) {
        if viewState == .todoList && CursorManager.shared.isCursorShown {
            selectedItemIndex = hovering ? index : -1
        }
    }

    func onCategoryListBackgroundTap() {
        viewState = .todoList
    }

    func isCategoryItemHovered(isSelected: Bool) -> Bool {
        return (isSelected && viewState == .category) || (isSelected && isTaggedInput)
    }

    func onCategoryItemHover(hovering: Bool, index: Int, currentState: TodoViewState) {
        if viewState == currentState && CursorManager.shared.isCursorShown {
            selectedItemIndex = hovering ? index : -1
        }
    }

    func onSuggestedListBackgroundTap() {
        viewState = .todoList
    }

    func onSuggestedTodoItemHover(hovering: Bool, index: Int) {
        if viewState == .todoInput && CursorManager.shared.isCursorShown {
            selectedItemIndex = hovering ? index : -1
        }
    }

    func handleKeyPress(_ keyPress: KeyPress, isTextfieldState _: Bool? = nil) -> KeyPress.Result {
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

    func scrollToTarget(proxy: ScrollViewProxy, currentViewState: TodoViewState) {
        if let target = scrollTarget, currentViewState == viewState {
            withAnimation {
                proxy.scrollTo(target, anchor: .center)
            }
        }
    }

    func handleTextFieldChange(_ newValue: String) {
        isJustSubmittedTodo = false
        let atPattern = #"@([^\s@]*)$"#

        if let match = newValue.range(of: atPattern, options: .regularExpression) {
            let afterAt = String(newValue[match].dropFirst())
            isTaggedInput = true
            selectedItemIndex = 0
            filterCategories(afterAt)
        } else if newValue.last == "@" {
            isTaggedInput = true
            selectedItemIndex = 0
            filteredCategories = categories
        } else if newValue.contains("@") {
            isTaggedInput = false
            selectedItemIndex = -1
            filterSuggestionTodos(newValue)
        } else {
            isTaggedInput = false
            selectedItemIndex = -1
            filterSuggestionTodos(newValue)
        }
    }

    func selectItem(_ item: Any, action: (() -> Void)? = nil) {
        switch viewState {
        case .category:
            if let selectedCategoryItem = item as? Category {
                selectedCategory = selectedCategoryItem
                viewState = .todoList
            }

        case .todoInput:
            if isTaggedInput && selectedItemIndex >= 0 && filteredCategories.count > 0 {
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
                    selectedCategory = newTodo.category
                    DataManager.shared.saveTodos(todos)
                    viewState = .todoList
                    todoInputText = ""
                }
            }

        case .todoList:
            if let newTodo = item as? Todo {
                if selectedTodoUidSet.contains(newTodo.id) {
                    selectedTodoUidSet.remove(newTodo.id)
                } else {
                    selectedTodoUidSet.insert(newTodo.id)
                }
            }
        }
        action?()
    }

    // MARK: - PRIVATE METHODS

    private func loadData() {
        categories = DataManager.shared.loadCategories()
        todos = DataManager.shared.loadTodos()
        selectedCategory = categories.first
        filteredCategories = categories
        filterSuggestionTodos("")
    }

    private func deferredMoveSelection(direction: MoveDirection) {
        Task { @MainActor in

            switch direction {
            case .up:
                selectedItemIndex = max(selectedItemIndex - 1, 0)
            case .down:
                selectedItemIndex = min(selectedItemIndex + 1, currentItems.count - 1)
            }
            isJustSubmittedTodo = false
            CursorManager.shared.hideCursor()
            scrollTarget = selectedItemIndex
        }
    }

    private func deferredHandleReturnKey() -> KeyPress.Result {
        Task { @MainActor in
            // Handle enter key in textfield wile not selecting any index item
            if viewState == .todoInput && todoInputText != "" && selectedItemIndex <= 0 && isRegularTextfield {
                self.submitTodoTextfield()
                return
            }

            if selectedItemIndex >= 0 && selectedItemIndex < currentItems.count {
                selectItem(currentItems[selectedItemIndex])
            }
            isJustSubmittedTodo = false
            selectedItemIndex = -1
            scrollTarget = 0
        }
        return .handled
    }

    private func submitTodoTextfield(action: (() -> Void)? = nil) {
        guard let selectedCategory else { return }
        let todo = Todo(name: todoInputText, category: selectedCategory)

        // find todo from todos with same name and category
        selectItem(todo) {
            self.isJustSubmittedTodo = true
            self.viewState = .todoInput
        }

        action?()
    }

    private func filterCategories(_ filter: String) {
        filteredCategories = categories.filter { category in
            category.name.lowercased().starts(with: filter.lowercased())
        }
    }

    private func filterSuggestionTodos(_ filter: String) {
        let lowercasedFilter = filter.lowercased()

        if lowercasedFilter == "" {
            filteredSuggestedTodos = Array(todos.prefix(5))
            return
        }

        filteredSuggestedTodos = Array(todos
            .filter { todo in
                todo.name.lowercased().starts(with: lowercasedFilter)
            }
            .sorted { $0.name.count < $1.name.count } // Sort by name length, shortest first
            .prefix(5)) // Take top 5 and convert to Array
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

    private func removeTagFromFocusText() {
        if let atIndex = todoInputText.lastIndex(of: "@") {
            todoInputText = String(todoInputText[..<atIndex]).trimmingCharacters(in: .whitespaces)
        }
    }
}
