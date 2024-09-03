//
//  TodoView.swift
//  SessionMacOS
//
//  Created by Hilmy Veradin on 03/09/24.
//

import SwiftUI

enum TodoViewState {
    case todo
    case category
    case focus
}

struct TodoView: View {
    @StateObject private var viewModel = TodoViewModel()
    @FocusState private var searchFocus: Bool
    
    var body: some View {
        ZStack {
            VStack {
                sessionHeader
                searchTextField
                todoList
            }
            
            switch viewModel.viewState {
            case .todo: EmptyView()
            case .category: categoryListView()
            case .focus: focusListView()
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
        .onChange(of: viewModel.filteredFocusItems) { _ in
            viewModel.updateKeyEventHandlerItems()
        }
    }
    
    private var sessionHeader: some View {
        HStack {
            Text(viewModel.selectedSession?.name ?? "Null")
            Spacer()
            Image(systemName: "chevron.down")
        }
        .padding()
        .background(.background)
        .onTapGesture { viewModel.viewState = .category }
        .frame(height: 50)
    }
    
    private var searchTextField: some View {
        TextField("What's your focus?", text: $viewModel.focusText)
            .padding()
            .background(.background)
            .frame(height: 50)
            .focused($searchFocus)
            .onChange(of: viewModel.focusText) { viewModel.handleTextFieldChange($0) }
            .onChange(of: searchFocus) { if $0 { viewModel.viewState = .focus }}
            .onSubmit {
                viewModel.selectItem(viewModel.focusText) {
                    searchFocus = false
                }
                
            }
    }
    
    private var todoList: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(Array(viewModel.todoItems.enumerated()), id: \.element) { index, item in
                    todoItemView(item: item, index: index)
                }
            }
            .onChange(of: viewModel.scrollTarget) { target in
                scrollToTarget(proxy: proxy, target: target)
            }
        }
    }
    
    private func todoItemView(item: String, index: Int) -> some View {
        HoverableButton(isPriority: viewModel.viewState == .todo, action: {
            viewModel.selectItem(item)
        }) {
            HStack {
                Image(systemName: "square")
                Text(item)
                Spacer()
                Text(viewModel.selectedSession?.name ?? "")
                    .font(.caption)
                    .foregroundColor(Color(hex: viewModel.selectedSession?.color ?? ""))
            }
        }
        .onHover { hovering in
            if hovering && viewModel.viewState == .todo {
                viewModel.keyEventHandler.selectedIndex = index
            } else {
                viewModel.keyEventHandler.selectedIndex = -1
            }
        }
        .id(index)
        .background((index == viewModel.keyEventHandler.selectedIndex && viewModel.viewState == .todo) ? Color.blue.opacity(0.2) : Color.clear)
    }
    
    private func categoryListView() -> some View {
        VStack {
            Color.black.opacity(0.001)
                .frame(height: 50)
                .onTapGesture { viewModel.viewState = .todo }
            
            ScrollViewReader { proxy in
                List {
                    ForEach(Array(viewModel.filteredCategoryItems.enumerated()), id: \.element) { index, item in
                        categoryItemView(item: item, index: index)
                    }
                }
                .frame(maxHeight: 200)
                .listStyle(.plain)
                .onChange(of: viewModel.scrollTarget) { target in
                    scrollToTarget(proxy: proxy, target: target)
                }
            }
            
            Color.black.opacity(0.01)
                .onTapGesture { viewModel.viewState = .todo }
        }
        .zIndex(2)
    }
    
    private func categoryItemView(item: String, index: Int) -> some View {
        HoverableButton(isPriority: viewModel.viewState == .category, action: {
            viewModel.selectItem(item)
        }) {
            HStack {
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundStyle(Color(hex: viewModel.colorItems[index]))
                Text(item)
                Spacer()
            }
        }
        .onHover { hovering in
            if hovering && viewModel.viewState == .category {
                viewModel.keyEventHandler.selectedIndex = index
            } else {
                viewModel.keyEventHandler.selectedIndex = -1
            }
        }
        .id(index)
        .background(((index == viewModel.keyEventHandler.selectedIndex && viewModel.viewState == .category) || (viewModel.isTagIntention && index == viewModel.keyEventHandler.selectedIndex)) ? Color.blue.opacity(0.2) : Color.clear)
    }
    
    private func focusListView() -> some View {
        VStack {
            Color.black.opacity(0.01)
                .frame(height: 110)
                .onTapGesture {
                    viewModel.viewState = .todo
                    searchFocus = false
                }
            
            ScrollViewReader { proxy in
                if viewModel.isTagIntention {
                    List {
                        ForEach(Array(viewModel.filteredCategoryItems.enumerated()), id: \.element) { index, item in
                            categoryItemView(item: item, index: index)
                        }
                    }
                    .frame(maxHeight: 200)
                    .listStyle(.plain)
                    .onChange(of: viewModel.scrollTarget) { target in
                        scrollToTarget(proxy: proxy, target: target)
                    }
                } else {
                    List {
                        ForEach(Array(viewModel.filteredFocusItems.enumerated()), id: \.element) { index, item in
                            focusItemView(item: item, index: index)
                        }
                    }
                    .frame(maxHeight: 200)
                    .listStyle(.plain)
                    .onChange(of: viewModel.scrollTarget) { target in
                        scrollToTarget(proxy: proxy, target: target)
                    }
                }
                
                Color.black.opacity(0.001)
                    .onTapGesture {
                        viewModel.viewState = .todo
                        searchFocus = false
                    }
            }

        }
        .zIndex(2)
    }
    
    private func focusItemView(item: String, index: Int) -> some View {
        HoverableButton(isPriority: viewModel.viewState == .focus, action: {
            viewModel.selectItem(item) {
                searchFocus = false
            }
        }) {
            HStack {
                Text(item)
                Spacer()
            }
        }
        .onHover { hovering in
            if hovering && viewModel.viewState == .focus {
                viewModel.keyEventHandler.selectedIndex = index
            } else {
                viewModel.keyEventHandler.selectedIndex = -1
            }
        }
        .id(index)
        .background((index == viewModel.keyEventHandler.selectedIndex && viewModel.viewState == .focus) ? Color.blue.opacity(0.2) : Color.clear)
    }
    
    private func scrollToTarget(proxy: ScrollViewProxy, target: Int?) {
        if let target = target {
            withAnimation {
                proxy.scrollTo(target, anchor: .center)
            }
        }
    }
}

#Preview {
    TodoView()
}
