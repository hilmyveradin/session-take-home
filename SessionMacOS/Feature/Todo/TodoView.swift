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
            VStack(spacing: 6) {
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
        TextField("", text: $viewModel.todoInputText, prompt: Text("What's your focus?")
            .font(.inter)
            .foregroundColor(.textPlaceholder)
            .fontWeight(.medium))
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(.background)
                .textFieldStyle(PlainTextFieldStyle())
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(viewModel.viewState == .todoInput ? Color.tintPrimary : Color.clear, lineWidth: 2)
                )
                .focused($viewFocus, equals: .todoInput)
                .onKeyPress(keys: [.upArrow, .downArrow, .return]) { keyPress in
                    viewModel.handleKeyPress(keyPress)
                }
                .onChange(of: viewModel.todoInputText) {
                    viewModel.handleTextFieldChange(viewModel.todoInputText)
                }
        }
    
    private var todoList: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(Array(viewModel.todos.enumerated()), id: \.element.id) { index, item in
                    todoItemView(item: item, index: index)
                }
            }
            .scrollIndicators(.never)
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .padding(EdgeInsets(top: 0, leading: -8, bottom: 0, trailing: -8))
            .focused($viewFocus, equals: .todoList)
            .onKeyPress(keys: [.upArrow, .downArrow, .return]) { keyPress in
                viewModel.handleKeyPress(keyPress)
            }
            .onChange(of: viewModel.scrollTarget) {
                viewModel.scrollToTarget(proxy: proxy, currentViewState: .todoList)
            }
        }
        .padding(.top, 28)
    }
    
    private func todoItemView(item: Todo, index: Int) -> some View {
        Group {
        HoverableButton(isPriority: viewModel.viewState == .todoList, action: {
            viewModel.selectItem(item)
        }) {
            HStack {
                Image(systemName: viewModel.selectedTodoUidSet.contains(item.id) ? "checkmark.square.fill" : "square")
                    .foregroundStyle(
                        viewModel.isItemViewHovered(index: index, currentState: .todoList) ? Color.white :
                        viewModel.selectedTodoUidSet.contains(item.id) ? Color.tintPrimary :
                        Color.textPrimary
                    )
                    

                
                VStack(alignment:.leading, spacing:0) {
                    Text(item.name)
                        .font(.inter)
                        .fontWeight(.medium)
                        .foregroundStyle(viewModel.isItemViewHovered(index: index, currentState: .todoList) ? Color.white : Color.textPrimary)

                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill( viewModel.isItemViewHovered(index: index, currentState: .todoList) ? Color.white : Color(hex: item.category.color) )
                            .frame(width: 6, height: 6)

                        Text(item.category.name.capitalized)
                            .font(.smallInter)
                            .foregroundStyle(viewModel.isItemViewHovered(index: index, currentState: .todoList) ? Color.white : Color.textSecondary)
                    }
                }
                Spacer()
            }
            .padding(.vertical, 10.5)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
        }
        .onHover { hovering in
            viewModel.onTodoItemHover(hovering: hovering, index: index)
        }
        .id(index)
        .background(viewModel.isItemViewHovered(index: index, currentState: .todoList) ? Color.tintPrimary : Color.white)
        .cornerRadius(4)
        .animation(.easeInOut, value: viewModel.isItemViewHovered(index: index, currentState: .todoList))
        .listRowSeparator(.hidden)
        }
        .padding(.bottom, 6)
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
                    .scrollIndicators(.never)
                    .scrollContentBackground(.hidden)
                    .background(.background)
                    .listStyle(.plain)
                    .padding(EdgeInsets(top: 0, leading: -8, bottom: 0, trailing: -8))
                    .focused($viewFocus, equals: .category)
                    .onKeyPress(keys: [.upArrow, .downArrow, .return]) { keyPress in
                        viewModel.handleKeyPress(keyPress)
                    }
                    .onChange(of: viewModel.scrollTarget) {
                        viewModel.scrollToTarget(proxy: proxy, currentViewState: .category)
                    }
                }
                .frame(height: viewModel.filteredCategories.isEmpty ? 0 : 180)
                .cornerRadius(4)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 30)
                Spacer()
            }
            .padding(.top, 54)
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
        }
        .onHover { hovering in
            viewModel.onCategoryItemHover(hovering: hovering, index: index, currentState: currentState)
        }
        .id(index)
        .background(viewModel.isItemViewHovered(index: index, currentState: currentState) ? Color.tintPrimary : Color.clear)
        .animation(.easeInOut, value: viewModel.isItemViewHovered(index: index, currentState: currentState))
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 1, leading: 0, bottom: 1, trailing: 0))
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
                            .listStyle(.plain)
                            .padding(EdgeInsets(top: 0, leading: -8, bottom: 0, trailing: -8))
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
                            .scrollIndicators(.never)
                            .frame(height: viewModel.filteredSuggestedTodos.isEmpty ? 0 : 200)
                            .listStyle(.plain)
                            .cornerRadius(4)
                            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 30)
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
                
            
            Text(item.name.capitalized)
                .foregroundStyle(viewModel.isItemViewHovered(index: index, currentState: .todoInput) ? Color.white : Color.textPrimary )

                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .onHover { hovering in
            viewModel.onSuggestedTodoItemHover(hovering: hovering, index: index)
        }
        .id(index)
        .background(viewModel.isItemViewHovered(index: index, currentState: .todoInput) ? Color.tintPrimary : Color.clear)
        .animation(.easeInOut, value: viewModel.isItemViewHovered(index: index, currentState: .todoInput))
        .listRowSeparator(.hidden)
    }
}

#Preview {
    TodoView()
}
