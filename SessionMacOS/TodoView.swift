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
    let action: () -> Void
    let content: () -> Content
    @State private var isHovering = false
    
    init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
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
    }
}

struct TodoView: View {
    @State private var focusText = ""
    @FocusState private var searchFocus: Bool
    
    @State private var selectedSuggestion: String?
    @State private var selectedSession: Session?
    
    @State private var mockSessionData: [Session] = []
    @State private var viewState: TodoViewState = .todo
    
    @StateObject private var keyEventHandler = KeyEventHandler()
    
    var filteredFocusItems: [String] {
        guard let category = selectedSession else { return [] }
        
        if focusText == "" {
            return category.focus
        } else {
            return category.focus.filter { $0.lowercased().contains(focusText.lowercased()) }
        }
        
    }
    
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
                    .onChange(of: searchFocus) { newValue in
                        if newValue {
                            viewState = .focus
                        }
                    }
                
//                // Base Todo View
                List {
                    ForEach(Array(getRelevantItems().enumerated()), id: \.element) { index, item in
                        HoverableButton(action: {
                            selectItem(item)
                        }) {
                            HStack {
                                Image(systemName: "square")
                                Text(item)
                                Spacer()
                                if viewState == .todo {
                                    Text(selectedSession?.name ?? "")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .background((index == keyEventHandler.selectedIndex && viewState == .todo) ? Color.blue.opacity(0.2) : Color.clear)
                    }
                }
            }
            
            switch viewState {
            case .todo:
                EmptyView()
            case .category:
                VStack {
                    Color.black.opacity(0.001)
                        .frame(height: 50)
                        .onTapGesture {
                            viewState = .todo
                        }
                    
                    // Category List View
                    List {
                        ForEach(Array(getRelevantItems().enumerated()), id: \.element) { index, item in

                            HoverableButton(action: {
                                selectItem(item)
                            }, content: {
                                HStack {
                                    Text(item)
                                    Spacer()
                                }
                                
                            })
                            .background((index == keyEventHandler.selectedIndex && viewState == .category) ? Color.blue.opacity(0.2) : Color.clear)
                            
                        }
                    }
                    .frame(maxHeight: 200)
                    .listStyle(.plain)
                    
                    Color.black.opacity(0.001)
                        .onTapGesture {
                            viewState = .todo
                        }

                }
                .zIndex(2)
            case .focus:
                VStack {
                    Color.black.opacity(0.001)
                        .frame(height: 110)
                        .onTapGesture {
                            viewState = .todo
                            searchFocus = false
                        }
                    
                    // Focus view list
                    List {
                        ForEach(Array(getRelevantItems().enumerated()), id: \.element) { index, item in
                            HoverableButton(action: {
                                selectItem(item)
                            }, content: {
                                HStack {
                                    Text(item)
                                    Spacer()
                                }
                                
                            })
                            .background((index == keyEventHandler.selectedIndex && viewState == .focus) ? Color.blue.opacity(0.2) : Color.clear)
                        }
                    }
                    .frame(maxHeight: 200)
                    .listStyle(.plain)
                    
                    Color.black.opacity(0.001)
                        .onTapGesture {
                            viewState = .todo
                            searchFocus = false
                        }
                }
                .zIndex(2)
            }
        }
        .onAppear {
            loadMockData()
            keyEventHandler.startMonitoring()
            keyEventHandler.onSelect = { selectItem($0) }
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
    
    private func updateKeyEventHandlerItems() {
        keyEventHandler.updateItems(getRelevantItems())
    }
    
    private func getRelevantItems() -> [String] {
        switch viewState {
        case .todo:
            return selectedSession?.list ?? []
        case .category:
            return mockSessionData.map { $0.name }
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
                viewState = .todo
                print("category button clicked")
            }
        case .focus:
            focusText = item
            viewState = .todo
            searchFocus = false
            print("focus intention clicked")
        }
    }
    
    private func loadMockData() {
        guard let url = Bundle.main.url(forResource: "MockData", withExtension: "json") else {
            print("MockData.json not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            mockSessionData = try decoder.decode([Session].self, from: data)
            selectedSession = mockSessionData[0]
        } catch {
            print("Error decoding MockData.json: \(error)")
        }
    }
}

#Preview {
    TodoView()
}
