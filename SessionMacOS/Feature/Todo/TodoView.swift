//
//  TodoView.swift
//  SessionMacOS
//
//  Created by Hilmy Veradin on 04/09/24.
//

import SwiftUI

struct TodoView: View {
    @StateObject private var viewModel = TodoViewModel()
    @FocusState private var viewFocus: TodoViewState?
    
    private var viewFocusBinding: Binding<TodoViewState?> {
        Binding(
            get: { self.viewFocus },
            set: { self.viewFocus = $0 }
        )
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                categoryHeader
                todoTextField
                todoList
            }
            .padding()
            
            switch viewModel.viewState {
            case .todoList: EmptyView()
            case .category: categoryListView()
            case .todoInput: suggestedTodoListView()
            }
        }
        .onAppear {
            viewModel.onAppear(viewFocus: viewFocusBinding)
        }
        .onChange(of: viewFocus) {
            viewModel.onFocusChange(newValue: viewFocus)
        }
        .onChange(of: viewModel.viewState) {
            viewModel.onViewStateChange(newValue: viewModel.viewState, viewFocus: viewFocusBinding)
        }
    }
    
    private var categoryHeader: some View {
        Button(action: { viewModel.onCategoryHeaderTap() }) {
            HStack {
                
                Circle()
                    .fill(Color(hex: viewModel.selectedCategory?.color ?? "#000000"))
                    .frame(width: 6, height: 6)

                Text(viewModel.selectedCategoryName)
                    .foregroundStyle(Color.textPrimary)
                    
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 8))
                    .frame(width: 8, height: 4)
                    .foregroundColor(.gray)
            }
            
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.background)
            .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var todoTextField: some View {
        HStack {
            TextField("What's your focus?", text: $viewModel.todoInputText)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .font(.system(size: 16, weight: .regular))
                .textFieldStyle(PlainTextFieldStyle())
                .focused($viewFocus, equals: .todoInput)
                .onKeyPress(keys: [.upArrow, .downArrow, .return]) { keyPress in
                    viewModel.handleKeyPress(keyPress)
                }
                .onChange(of: viewModel.todoInputText) {
                    viewModel.handleTextFieldChange(viewModel.todoInputText)
                }
            
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.horizontal, 12)
        }
        .background(.background)
        .accentColor(.gray)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(20)
        .padding(.horizontal, 36)
    }
    
    private var todoList: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(Array(viewModel.todos.enumerated()), id: \.element.id) { index, item in
                    todoItemView(item: item, index: index)
                }
            }
            .listStyle(PlainListStyle())
            .cornerRadius(10)
            .focused($viewFocus, equals: .todoList)
            .onKeyPress(keys: [.upArrow, .downArrow, .return]) { keyPress in
                viewModel.handleKeyPress(keyPress)
            }
            .onChange(of: viewModel.scrollTarget) {
                viewModel.scrollToTarget(proxy: proxy, currentViewState: .todoList)
            }
        }
        .cardStyle()
    }
    
    private func todoItemView(item: Todo, index: Int) -> some View {
        HoverableButton(isPriority: viewModel.viewState == .todoList, action: {
            viewModel.selectItem(item)
        }) {
            HStack {
                Image(systemName: viewModel.selectedTodoUidSet.contains(item.id) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(viewModel.selectedTodoUidSet.contains(item.id) ? .accentColor : .gray)
                Text(item.name)
                    .foregroundColor(.primary)
                Spacer()
                Text(item.category.name.capitalized)
                    .font(.caption)
                    .foregroundColor(Color(hex: item.category.color))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: item.category.color).opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .contentShape(Rectangle())
        }
        .onHover { hovering in
            viewModel.onTodoItemHover(hovering: hovering, index: index)
        }
        .id(index)
        .background(viewModel.isItemViewHovered(index: index, currentState: .todoList) ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .animation(.easeInOut, value: viewModel.isItemViewHovered(index: index, currentState: .todoList))
    }
    
    private func categoryListView() -> some View {
        ZStack {
            Color.black.opacity(0.001)
                .onTapGesture {
                    viewModel.onCategoryListBackgroundTap()
                }
                VStack {
                    ScrollViewReader { proxy in
                        List {
                            ForEach(Array(viewModel.filteredCategories.enumerated()), id: \.element.id) { index, item in
                                categoryItemView(item: item, index: index)

                            }
                        }
                        .frame(height: viewModel.filteredCategories.isEmpty ? 0 : 200)
                        .listStyle(.plain)
                        .cornerRadius(4)
                        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 30)
                        .focused($viewFocus, equals: .category)
                        .onKeyPress(keys: [.upArrow, .downArrow, .return]) { keyPress in
                            viewModel.handleKeyPress(keyPress)
                        }
                        .onChange(of: viewModel.scrollTarget) {
                            viewModel.scrollToTarget(proxy: proxy, currentViewState: .category)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, 60)
                .zIndex(2)
            }
        .padding(.horizontal, 16)
    }
    
    private func categoryItemView(item: Category, index: Int, currentState: TodoViewState = .category) -> some View {
        HoverableButton(isPriority: viewModel.viewState == currentState, action: {
            viewModel.selectItem(item)
        }) {
            HStack {
                Circle()
                    .fill( viewModel.isItemViewHovered(index: index, currentState: currentState) ? Color.white : Color(hex: item.color) )
                    .frame(width: 8, height: 8)

                Text(item.name.capitalized)
                    .foregroundStyle(viewModel.isItemViewHovered(index: index, currentState: currentState) ? Color.white : Color.textPrimary )
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .cornerRadius(20)
        }
        .onHover { hovering in
            viewModel.onCategoryItemHover(hovering: hovering, index: index, currentState: currentState)
        }
        .id(index)
        .background(viewModel.isItemViewHovered(index: index, currentState: currentState) ? Color.tintPrimary : Color.clear)
        .cornerRadius(8)
        .animation(.easeInOut, value: viewModel.isItemViewHovered(index: index, currentState: currentState))
        .listRowSeparator(.hidden)
    }
    
    private func suggestedTodoListView() -> some View {
        if viewModel.isJustSubmittedTodo {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            VStack {
                Color.black.opacity(0.001)
                    .onTapGesture {
                        viewModel.onSuggestedListBackgroundTap()
                    }
                    .frame(height: 96)
                
                Group {
                    ScrollViewReader { proxy in
                        if viewModel.isTaggedInput {
                            List {
                                ForEach(Array(viewModel.filteredCategories.enumerated()), id: \.element.id) { index, item in
                                    categoryItemView(item: item, index: index, currentState: .todoInput)
                                }
                            }
                            .frame(height: viewModel.filteredCategories.isEmpty ? 0 : 200)
                            .listStyle(PlainListStyle())
                            .cornerRadius(10)
                            .focused($viewFocus, equals: .todoInput)
                            .onKeyPress(keys: [.upArrow, .downArrow, .return]) { keyPress in
                                viewModel.handleKeyPress(keyPress)
                                return .handled
                            }
                            .onChange(of: viewModel.scrollTarget) { _ in
                                viewModel.scrollToTarget(proxy: proxy, currentViewState: .todoInput)
                            }
                        } else {
                            List {
                                ForEach(Array(viewModel.filteredSuggestedTodos.enumerated()), id: \.element.id) { index, item in
                                    suggestedTodoItemView(item: item, index: index)
                                }
                            }
                            .frame(height: viewModel.filteredSuggestedTodos.isEmpty ? 0 : 200)
                            .listStyle(PlainListStyle())
                            .cornerRadius(10)
                            .focused($viewFocus, equals: .todoInput)
                            .onKeyPress(keys: [.upArrow, .downArrow, .return]) { keyPress in
                                viewModel.handleKeyPress(keyPress)
                                return .handled
                            }
                            .onChange(of: viewModel.scrollTarget) { _ in
                                viewModel.scrollToTarget(proxy: proxy, currentViewState: .todoInput)
                            }
                        }
                    }
                    .cardStyle()
                    .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal, 36)
                .padding(.top, 24)
                
                Color.black.opacity(0.001)
                    .onTapGesture {
                        viewModel.onSuggestedListBackgroundTap()
                    }
                    .frame(maxHeight: .infinity)
            }
            .zIndex(2)
        )
    }
    
    private func suggestedTodoItemView(item: Todo, index: Int) -> some View {
        HoverableButton(isPriority: viewModel.viewState == .todoInput, action: {
            viewModel.selectItem(item)
        }) {
            HStack {
                Text(item.name)
                    .foregroundColor(.primary)
                Spacer()
                Text(item.category.name.capitalized)
                    .font(.caption)
                    .foregroundColor(Color(hex: item.category.color))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: item.category.color).opacity(0.2))
                    .cornerRadius(8)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .contentShape(Rectangle())
        }
        .onHover { hovering in
            viewModel.onSuggestedTodoItemHover(hovering: hovering, index: index)
        }
        .id(index)
        .background(viewModel.isItemViewHovered(index: index, currentState: .todoInput) ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .animation(.easeInOut, value: viewModel.isItemViewHovered(index: index, currentState: .todoInput))
    }
}

#Preview {
    TodoView()
}
