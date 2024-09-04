//
//  NewTodo.swift
//  SessionMacOS
//
//  Created by Hilmy Veradin on 04/09/24.
//

import SwiftUI

struct TodoView: View {
    @StateObject private var viewModel = TodoViewModel()
    @FocusState private var searchFocus: Bool
    
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
            viewModel.keyEventHandler.startMonitoring()
        }
        .onDisappear {
            viewModel.keyEventHandler.stopMonitoring()
        }
        .onChange(of: viewModel.viewState) { _ in
            viewModel.updateKeyEventHandlerItems()
        }
        .onChange(of: viewModel.isTaggedInput) { _ in
            viewModel.updateKeyEventHandlerItems()
        }
    }
    
    private var categoryHeader: some View {
        HStack {
            Text(viewModel.selectedCategory?.name ?? "No Category Found")
            Spacer()
            Image(systemName: "chevron.down")
        }
        .padding()
        .background(.background)
        .onTapGesture { viewModel.viewState = .category }
        .frame(height: 50)
    }
    
    private var todoTextField: some View {
        TextField("What's your focus?", text: $viewModel.todoInputText)
            .padding()
            .background(.background)
            .frame(height: 50)
            .focused($searchFocus)
            .onChange(of: viewModel.todoInputText) { viewModel.handleTextFieldChange($0) }
            .onChange(of: searchFocus) { if $0 { viewModel.viewState = .todoInput }}
            .onSubmit {
                viewModel.selectItem() {
                    searchFocus = false
                }
            }
    }
    
    private var todoList: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(Array(viewModel.todos.enumerated()), id: \.element.id) { index, item in
                    todoItemView(item: item, index: index)
                }
            }
            .onChange(of: viewModel.scrollTarget) { target in
                scrollToTarget(proxy: proxy, target: target, currentViewState: .todoList)
            }
        }
    }
    
    private func todoItemView(item: Todo, index: Int) -> some View {
        let isSelected = index == viewModel.keyEventHandler.selectedIndex
        let isHovered = isSelected && viewModel.viewState == .todoList
        
        return HoverableButton(isPriority: viewModel.viewState == .todoList, action: {
            viewModel.selectItem(item)
        }) {
            HStack {
                Image(systemName: "square")
                Text(item.name)
                Spacer()
                Text(item.category.name )
                    .font(.caption)
                    .foregroundColor(Color(hex: item.category.color ))
            }
        }
        .onHover { hovering in
            if viewModel.viewState == .todoList {
                viewModel.keyEventHandler.selectedIndex = hovering ? index : -1
            }
        }
        .id(index)
        .background(isHovered ? Color.blue.opacity(0.2) : Color.clear)
    }
    
    private func categoryListView() -> some View {
        VStack {
            Color.black.opacity(0.01)
                .frame(height: 50)
                .onTapGesture { viewModel.viewState = .todoList }
            
            ScrollViewReader { proxy in
                List {
                    ForEach(Array(viewModel.filteredCategories.enumerated()), id: \.element.id) { index, item in
                        categoryItemView(item: item, index: index)
                    }
                }
                .frame(height: viewModel.filteredCategories.isEmpty ? 0 : 200)
                .listStyle(.plain)
                .shadow(color: Color.gray, radius: 5, x: 5, y: 15)
                .onChange(of: viewModel.scrollTarget) { target in
                    scrollToTarget(proxy: proxy, target: target, currentViewState: .category)
                }
                
            }
            
            Color.black.opacity(0.01)
                .onTapGesture { viewModel.viewState = .todoList }
        }
        .zIndex(2)
    }
    
    private func categoryItemView(item: Category, index: Int) -> some View {
        let isSelected = index == viewModel.keyEventHandler.selectedIndex
        let isHovered = (isSelected && viewModel.viewState == .category) || (isSelected && viewModel.isTaggedInput)
        
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
            if viewModel.viewState == .category {
                viewModel.keyEventHandler.selectedIndex = hovering ? index : -1
            }
        }
        .id(index)
        .background(isHovered ? Color.blue.opacity(0.2) : Color.clear)
    }
    
    private func suggestedTodoListView() -> some View {
        VStack {
            Color.black.opacity(0.01)
                .frame(height: 110)
                .onTapGesture {
                    viewModel.viewState = .todoList
                    searchFocus = false
                }
            
            ScrollViewReader { proxy in
                // If tagged input then make the list as categories. If not, use suggestedTodoItemView
                if viewModel.isTaggedInput {
                    List {
                        ForEach(Array(viewModel.filteredCategories.enumerated()), id: \.element.id) { index, item in
                            categoryItemView(item: item, index: index)
                        }
                    }
                    .frame(height: viewModel.filteredCategories.isEmpty ? 0 : 200)
                    .listStyle(.plain)
                    .shadow(color: Color.gray, radius: 5, x: 5, y: 15)
                    .onChange(of: viewModel.scrollTarget) { target in
                        scrollToTarget(proxy: proxy, target: target, currentViewState: .category)
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
                    .onChange(of: viewModel.scrollTarget) { target in
                        scrollToTarget(proxy: proxy, target: target, currentViewState: .todoInput)
                    }
                }
                
                Color.black.opacity(0.001)
                    .onTapGesture {
                        viewModel.viewState = .todoList
                        searchFocus = false
                    }
            }

        }
        .zIndex(2)
    }
    
    private func suggestedTodoItemView(item: Todo, index: Int) -> some View {
        let isSelected = index == viewModel.keyEventHandler.selectedIndex
        let isHovered = isSelected && viewModel.viewState == .todoInput
        
        return HoverableButton(isPriority: viewModel.viewState == .todoInput, action: {
            viewModel.selectItem(item)
        }) {
            HStack {
                Text(item.name)
                Spacer()
                Text(item.category.name )
                    .font(.caption)
                    .foregroundColor(Color(hex: item.category.color ))
            }
        }
        .onHover { hovering in
            if viewModel.viewState == .todoInput {
                viewModel.keyEventHandler.selectedIndex = hovering ? index : -1
            }
        }
        .id(index)
        .background(isHovered ? Color.blue.opacity(0.2) : Color.clear)
    }
    
    
    private func scrollToTarget(proxy: ScrollViewProxy, target: Int?, currentViewState: TodoViewState) {
        if let target, currentViewState == viewModel.viewState {
            withAnimation {
                proxy.scrollTo(target, anchor: .center)
            }
        }
    }
    
}

#Preview {
    TodoView()
}
