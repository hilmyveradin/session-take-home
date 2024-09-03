//
//  ContentView.swift
//  Session-Take-Home
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
    @State private var selectedCategory: Category?
    
    @State private var mockCategoryData: [Category] = []
    @State private var viewState: TodoViewState = .none
    
    var filteredFocusItems: [String] {
        guard let category = selectedCategory else { return [] }
        
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
                    Text(selectedCategory?.name ?? "Null")
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(.background)
                .onTapGesture {
                    viewState = .category
                }
                .frame(height: 50)
                .hoverEffect(.highlight)
                
                TextField("What's your focus?", text: $focusText)
                    .padding()
                    .background(.background)
                    .onTapGesture {
                        viewState = .focus
                        searchFocus = true
                    }
                    .frame(height: 50)
                    .focused($searchFocus)
                    .hoverEffect(.highlight)
                
                List {
                    ForEach(selectedCategory?.list ?? [], id: \.self) { list in
                        HoverableButton(action: {
                            
                        }, content: {
                            HStack {
                                Image(systemName: "square")
                                Text(list)
                                Spacer()
                                Text(selectedCategory?.name ?? "")
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
                        ForEach(mockCategoryData) { category in
                            
                            HoverableButton(action: {
                                selectedCategory = category
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
            mockCategoryData = try decoder.decode([Category].self, from: data)
            selectedCategory = mockCategoryData[0]
        } catch {
            print("Error decoding MockData.json: \(error)")
        }
    }
}

#Preview {
    TodoView()
}
