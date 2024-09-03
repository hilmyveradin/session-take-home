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

struct TodoView: View {
    @State private var focusText = ""
    @FocusState private var searchFocus: Bool
    
    @State private var selectedSuggestion: String?
    @State private var selectedCategory: Category?
    
    @State private var mockCategoryData: [Category] = []
    @State private var viewState: TodoViewState = .none
    
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
                
                TextField("What's your focus?", text: $focusText)
                    .padding()
                    .background(.background)
                    .onTapGesture {
                        viewState = .focus
                        searchFocus = true
                    }
                    .frame(height: 50)
                    .focused($searchFocus)
                
                List {
                    ForEach(selectedCategory?.list ?? [], id: \.self) { list in
                        HStack {
                            Image(systemName: "square")
                            Text(list)
                            Spacer()
                            Text(selectedCategory?.name ?? "")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
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
                            Button(action: {
                                selectedCategory = category
                                viewState = .none
                            }, label: {
                                Text(category.name)
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
                        ForEach(selectedCategory?.focus ?? [], id: \.self) { focus in
                            Button(action: {
                                viewState = .none
                                searchFocus = false
                            }, label: {
                                Text(focus)
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
