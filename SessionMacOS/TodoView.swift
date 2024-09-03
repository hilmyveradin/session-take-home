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

struct HoverableButton<Content: View>: View {
    let isPriority: Bool
    let action: () -> Void
    let content: () -> Content
    @State private var isHovering = false
    
    init(isPriority: Bool, action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.isPriority = isPriority
        self.action = action
        self.content = content
    }
    
    var body: some View {
        Button(action: action) {
            content()
                .padding(8)
                .background(isHovering ? Color.blue.opacity(0.2) : Color.clear)
                .cornerRadius(5)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovering = hovering
        }
        .allowsHitTesting(isPriority)
    }
}

struct TodoView: View {
    @State private var focusText = ""
    @FocusState private var searchFocus: Bool
    
    @State private var selectedSession: Session?
    @State private var mockSessionData: [Session] = []
    
    @State private var todoItems: [String] = []
    @State private var categoryItems: [String] = []
    @State private var focusItems: [String] = []
    
    @State private var filteredCategoryItems: [String] = []
    @State private var filteredFocusItems: [String] = []
    
    @State private var viewState: TodoViewState = .todo
    @State private var scrollTarget: Int?
    
    @State private var isTagIntention = false
    
    @StateObject private var keyEventHandler = KeyEventHandler()
    
    var body: some View {

        ZStack {
            VStack {
                HStack {
                    Text(selectedSession?.name ?? "Null")
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(.background)
                .onTapGesture {
                    viewState = .category
                }
                .frame(height: 50)
                
                TextField("What's your focus?", text: $focusText)
                    .padding()
                    .background(.background)
                    .frame(height: 50)
                    .focused($searchFocus)
                    .onChange(of: focusText) { newValue in
                        handleTextFieldChange(newValue)
                    }
                    .onChange(of: searchFocus) { newValue in
                        if newValue {
                            viewState = .focus
                        }
                    }

                
                // Base Todo View
                ScrollViewReader { proxy in
                    List {
                        ForEach(Array(todoItems.enumerated()), id: \.element) { index, item in
                            todoItemView(item: item, index: index)
                        }
                    }
                    .onChange(of: scrollTarget) { target in
                        scrollToTarget(proxy: proxy, target: target)
                    }
                }

            }
            
            switch viewState {
            case .todo:
                EmptyView()
            case .category:
                categoryListView()
            case .focus:
                focusListView()
            }
        }
        .onAppear {
            loadMockData()
            keyEventHandler.startMonitoring()
            keyEventHandler.onSelect = { selectItem($0) }
            keyEventHandler.onScroll = { index in
                scrollTarget = index
            }
        }
        .onDisappear {
            keyEventHandler.stopMonitoring()
        }
        .onChange(of: viewState) { _ in
            updateKeyEventHandlerItems()
        }
        .onChange(of: filteredFocusItems) { _ in
            updateKeyEventHandlerItems()
        }
    }
    
    // MARK: - View
    private func todoItemView(item: String, index: Int) -> some View {
        HoverableButton(isPriority: viewState == .todo, action: {
            selectItem(item)
        }, content: {
            HStack {
                Image(systemName: "square")
                Text(item)
                Spacer()
                Text(selectedSession?.name ?? "")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        })
        .id(index)
        .background((index == keyEventHandler.selectedIndex && viewState == .todo) ? Color.blue.opacity(0.2) : Color.clear)
    }

    private func categoryListView() -> some View {
        VStack {
            Color.black.opacity(0.1)
                .frame(height: 50)
                .onTapGesture {
                    viewState = .todo
                }
            
            ScrollViewReader { proxy in
                List {
                    ForEach(Array(filteredCategoryItems.enumerated()), id: \.element) { index, item in
                        categoryItemView(item: item, index: index)
                    }
                }
                .frame(maxHeight: 200)
                .listStyle(.plain)
                .onChange(of: scrollTarget) { target in
                    scrollToTarget(proxy: proxy, target: target)
                }
            }
            
            Color.black.opacity(0.1)
                .onTapGesture {
                    viewState = .todo
                }
        }
        .zIndex(2)
    }

    private func categoryItemView(item: String, index: Int) -> some View {
        HoverableButton(isPriority: viewState == .category, action: {
            selectItem(item)
        }, content: {
            HStack {
                Text(item)
                Spacer()
            }
        })
        .id(index)
        .background(((index == keyEventHandler.selectedIndex && viewState == .category) || (isTagIntention && index == keyEventHandler.selectedIndex)) ? Color.blue.opacity(0.2) : Color.clear)
    }

    private func focusListView() -> some View {
        VStack {
            Color.black.opacity(0.1)
                .frame(height: 110)
                .onTapGesture {
                    viewState = .todo
                    searchFocus = false
                }
            
            ScrollViewReader { proxy in
                if isTagIntention {
                    ScrollViewReader { proxy in
                        List {
                            ForEach(Array(filteredCategoryItems.enumerated()), id: \.element) { index, item in
                                categoryItemView(item: item, index: index)
                            }
                        }
                        .frame(maxHeight: 200)
                        .listStyle(.plain)
                        .onChange(of: scrollTarget) { target in
                            scrollToTarget(proxy: proxy, target: target)
                        }
                    }
                } else {
                    List {
                        ForEach(Array(filteredFocusItems.enumerated()), id: \.element) { index, item in
                            focusItemView(item: item, index: index)
                        }
                    }
                    .frame(maxHeight: 200)
                    .listStyle(.plain)
                    .onChange(of: scrollTarget) { target in
                        scrollToTarget(proxy: proxy, target: target)
                    }
                }

            }
            
            Color.black.opacity(0.001)
                .onTapGesture {
                    viewState = .todo
                    searchFocus = false
                }
        }
        .zIndex(2)
    }

    private func focusItemView(item: String, index: Int) -> some View {
        HoverableButton(isPriority: viewState == .focus, action: {
            selectItem(item)
        }, content: {
            HStack {
                Text(item)
                Spacer()
            }
        })
        .id(index)
        .background((index == keyEventHandler.selectedIndex && viewState == .focus) ? Color.blue.opacity(0.2) : Color.clear)
    }

    private func scrollToTarget(proxy: ScrollViewProxy, target: Int?) {
        if let target = target {
            withAnimation {
                proxy.scrollTo(target, anchor: .center)
            }
        }
    }
    
    // MARK: - Logic
    private func handleTextFieldChange(_ newValue: String) {
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
        if filter == "" {
            filteredFocusItems = focusItems
        } else {
            filteredFocusItems = focusItems.filter { $0.lowercased().contains(filter.lowercased()) }
        }

    }
    
    private func updateKeyEventHandlerItems() {
        keyEventHandler.updateItems(getRelevantItems())
    }
    
    private func getRelevantItems() -> [String] {
        
        if isTagIntention {
            return filteredCategoryItems
        }
        
        switch viewState {
        case .todo:
            return todoItems
        case .category:
            return filteredCategoryItems
        case .focus:
            return filteredFocusItems
            
        }
    }
    
    private func selectItem(_ item: String) {
        switch viewState {
        case .todo:
            print("todo button clicked")
        case .category:
            if let session = mockSessionData.first(where: { $0.name == item }) {
                selectedSession = session
                
                todoItems = selectedSession?.list ?? []
                categoryItems = mockSessionData.map { $0.name }
                focusItems = selectedSession?.focus ?? []
                
                filteredCategoryItems = categoryItems
                filteredFocusItems = focusItems
                
                viewState = .todo
                if let atIndex = focusText.firstIndex(of: "@") {
                    focusText = String(focusText[..<atIndex]).trimmingCharacters(in: .whitespaces)
                }
                print("category button clicked")
            }
        case .focus:
            
            if isTagIntention {
                if let session = mockSessionData.first(where: { $0.name == item }) {
                    selectedSession = session
                    
                    todoItems = selectedSession?.list ?? []
                    categoryItems = mockSessionData.map { $0.name }
                    focusItems = selectedSession?.focus ?? []
                    
                    filteredCategoryItems = categoryItems
                    filteredFocusItems = focusItems
                    
                    viewState = .todo
                    if let atIndex = focusText.firstIndex(of: "@") {
                        focusText = String(focusText[..<atIndex]).trimmingCharacters(in: .whitespaces)
                    }
                    print("category button clicked")
                }
            } else {
                focusText = item
            }
            
            viewState = .todo
            searchFocus = false
            print("focus intention clicked")
        }
        updateKeyEventHandlerItems()
    }
    
    private func loadMockData() {
        guard let url = Bundle.main.url(forResource: "MockData", withExtension: "json") else {
            print("MockData.json not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let sessionJsonData = try decoder.decode([Session].self, from: data)
            
            mockSessionData = sessionJsonData
            selectedSession = sessionJsonData[0]
            
            todoItems = selectedSession?.list ?? []
            categoryItems = mockSessionData.map { $0.name }
            focusItems = selectedSession?.focus ?? []
            
            filteredCategoryItems = categoryItems
            filteredFocusItems = focusItems
        } catch {
            print("Error decoding MockData.json: \(error)")
        }
    }
}

#Preview {
    TodoView()
}
