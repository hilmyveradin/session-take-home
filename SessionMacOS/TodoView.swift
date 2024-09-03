//
//  TodoView.swift
//  SessionMacOS
//
//  Created by Hilmy Veradin on 03/09/24.
//

import SwiftUI

enum TodoViewState {
    case none
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
    @State private var viewState: TodoViewState = .none
    
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
                    .onTapGesture {

                        searchFocus = true
                    }
                    .frame(height: 50)
                    .focused($searchFocus)
                    .onChange(of: searchFocus) { newValue in
                        if newValue {
                            viewState = .focus
                        }
                    }
                
                List {
                    ForEach(selectedSession?.list ?? [], id: \.self) { list in
                        HoverableButton(action: {
                        }, content: {
                            HStack {
                                Image(systemName: "square")
                                Text(list)
                                Spacer()
                                Text(selectedSession?.name ?? "")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        })

                    }
                }
            }
            
            switch viewState {
            case .none:
                EmptyView()
            case .category:
                VStack {
                    Color.black.opacity(0.001)
                        .frame(height: 50)
                        .onTapGesture {
                            viewState = .none
                        }
                    
                    List {
                        ForEach(mockSessionData) { category in
                            
                            HoverableButton(action: {
                                selectedSession = category
                                viewState = .none
                            }, content: {
                                HStack {
                                    Text(category.name)
                                    Spacer()
                                }
                                
                            })
                            
                        }
                    }
                    .frame(maxHeight: 200)
                    .background(.background)
                    .listStyle(.plain)
                    
                    Color.black.opacity(0.001)
                        .onTapGesture {
                            viewState = .none
                        }

                }
                .zIndex(2)
            case .focus:
                VStack {
                    Color.black.opacity(0.001)
                        .frame(height: 110)
                        .onTapGesture {
                            viewState = .none
                            searchFocus = false
                        }
                    
                    List {
                        ForEach(filteredFocusItems, id: \.self) { focus in
                            HoverableButton(action: {
                                viewState = .none
                                searchFocus = false
                            }, content: {
                                HStack {
                                    Text(focus)
                                    Spacer()
                                }
                                
                            })
                        }
                    }
                    .frame(maxHeight: 200)
                    .background(.background)
                    .listStyle(.plain)
                    
                    Color.black.opacity(0.001)
                        .onTapGesture {
                            viewState = .none
                            searchFocus = false
                        }
                }
                .zIndex(2)
            }
        }
        .onAppear {
            loadMockData()
        }
    }
    
    func loadMockData() {
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
