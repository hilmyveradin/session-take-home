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
            VStack {
                categoryHeader
                todoTextField
                todoList
            }
            
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
        .alert(isPresented: viewModel.isShowTodoAlertBinding) {
            Alert(title: Text(viewModel.todoAlertMessage))
        }
    }
    
    private var categoryHeader: some View {
        HStack {
            Text(viewModel.selectedCategoryName)
            Spacer()
            Image(systemName: "chevron.down")
        }
        .padding()
        .background(.background)
        .onTapGesture { viewModel.onCategoryHeaderTap() }
        .frame(height: 50)
    }
    
    private var todoTextField: some View {
        TextField("What's your focus?", text: $viewModel.todoInputText)
            .padding()
            .background(.background)
            .frame(height: 50)
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
            .focused($viewFocus, equals: .todoList)
            .onKeyPress(keys: [.upArrow, .downArrow, .return]) { keyPress in
                viewModel.handleKeyPress(keyPress)
            }
            .onChange(of: viewModel.scrollTarget) {
                viewModel.scrollToTarget(proxy: proxy, currentViewState: .todoList)
            }
        }
    }
    
    private func todoItemView(item: Todo, index: Int) -> some View {
        
        return HoverableButton(isPriority: viewModel.viewState == .todoList, action: {
            viewModel.selectItem(item)
        }) {
            HStack {
                Image(systemName: "square")
                Text(item.name)
                Spacer()
                Text(item.category.name)
                    .font(.caption)
                    .foregroundColor(Color(hex: item.category.color))
            }
        }
        .onHover { hovering in
            viewModel.onTodoItemHover(hovering: hovering, index: index)
        }
        .id(index)
        .background(viewModel.isItemViewHovered(index: index, currentState: .todoList) ? Color.blue.opacity(0.2) : Color.clear)
    }
    
    private func categoryListView() -> some View {
        VStack {
            Color.black.opacity(0.01)
                .frame(height: 50)
                .onTapGesture {
                    viewModel.onCategoryListBackgroundTap()
                }
            
            ScrollViewReader { proxy in
                List {
                    ForEach(Array(viewModel.filteredCategories.enumerated()), id: \.element.id) { index, item in
                        categoryItemView(item: item, index: index)
                    }
                }
                .frame(height: viewModel.filteredCategories.isEmpty ? 0 : 200)
                .listStyle(.plain)
                .shadow(color: Color.gray, radius: 5, x: 5, y: 15)
                .focused($viewFocus, equals: .category)
                .onKeyPress(keys: [.upArrow, .downArrow, .return]) { keyPress in
                    viewModel.handleKeyPress(keyPress)
                }
                .onChange(of: viewModel.scrollTarget) {
                    viewModel.scrollToTarget(proxy: proxy, currentViewState: .category)
                }
            }
            
            Color.black.opacity(0.01)
                .onTapGesture { viewModel.onCategoryListBackgroundTap() }
        }
        .zIndex(2)
    }
    
    private func categoryItemView(item: Category, index: Int) -> some View {
        return HoverableButton(isPriority: viewModel.viewState == .category, action: {
            viewModel.selectItem(item)
        }) {
            HStack {
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundStyle(Color(hex: item.color))
                Text(item.name)
                Spacer()
            }
        }
        .onHover { hovering in
            viewModel.onCategoryItemHover(hovering: hovering, index: index)
        }
        .id(index)
        .background(viewModel.isItemViewHovered(index: index, currentState: .category) ? Color.blue.opacity(0.2) : Color.clear)
    }
    
    private func suggestedTodoListView() -> some View {
        VStack {
            Color.black.opacity(0.01)
                .frame(height: 110)
                .onTapGesture {
                    viewModel.onSuggestedListBackgroundTap()
                }
            
            ScrollViewReader { proxy in
                if viewModel.isTaggedInput {
                    List {
                        ForEach(Array(viewModel.filteredCategories.enumerated()), id: \.element.id) { index, item in
                            categoryItemView(item: item, index: index)
                        }
                    }
                    .frame(height: viewModel.filteredCategories.isEmpty ? 0 : 200)
                    .listStyle(.plain)
                    .shadow(color: Color.gray, radius: 5, x: 5, y: 15)
                    .focused($viewFocus, equals: .todoInput)
                    .onKeyPress(keys: [.upArrow, .downArrow, .return]) { keyPress in
                        viewModel.handleKeyPress(keyPress)
                    }
                    .onChange(of: viewModel.scrollTarget) {
                        viewModel.scrollToTarget(proxy: proxy, currentViewState: .category)
                    }
                } else {
                    List {
                        ForEach(Array(viewModel.filteredSuggestedTodos.enumerated()), id: \.element.id) { index, item in
                            suggestedTodoItemView(item: item, index: index)
                        }
                    }
                    .frame(height: viewModel.filteredSuggestedTodos.isEmpty ? 0 : 200)
                    .listStyle(.plain)
                    .shadow(color: Color.gray, radius: 5, x: 5, y: 15)
                    .focused($viewFocus, equals: .todoInput)
                    .onKeyPress(keys: [.upArrow, .downArrow, .return]) { keyPress in
                        viewModel.handleKeyPress(keyPress)
                    }
                    .onChange(of: viewModel.scrollTarget) {
                        viewModel.scrollToTarget(proxy: proxy, currentViewState: .todoInput)
                    }
                }
                
                Color.black.opacity(0.001)
                    .onTapGesture {
                        viewModel.onSuggestedListBackgroundTap()
                    }
            }
        }
        .zIndex(2)
    }
    
    private func suggestedTodoItemView(item: Todo, index: Int) -> some View {
        
        return HoverableButton(isPriority: viewModel.viewState == .todoInput, action: {
            viewModel.selectItem(item)
        }) {
            HStack {
                Text(item.name)
                Spacer()
                Text(item.category.name)
                    .font(.caption)
                    .foregroundColor(Color(hex: item.category.color))
            }
        }
        .onHover { hovering in
            viewModel.onSuggestedTodoItemHover(hovering: hovering, index: index)
        }
        .id(index)
        .background(viewModel.isItemViewHovered(index: index, currentState: .todoInput) ? Color.blue.opacity(0.2) : Color.clear)
    }
}

#Preview {
    TodoView()
}
