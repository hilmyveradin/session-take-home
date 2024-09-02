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
    
    @State private var mockCategoryData: [CategoryData] = []
    @State private var viewState: TodoViewState = .none
    
    var body: some View {
        
        ZStack {
            VStack {
                HStack {
                    Text("Categories")
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
                    ForEach(0..<10) { _ in
                        HStack {
                            Image(systemName: "square")
                            Text("Designing interface")
                            Spacer()
                            Text("Categories")
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
                                            Text("Design").foregroundColor(.red)
                                            Text("Programming").foregroundColor(.yellow)
                                            Text("Marketing").foregroundColor(.green)
                                            Text("Finance").foregroundColor(.mint)
                                            Text("Support").foregroundColor(.blue)
                                            Text("Sleep").foregroundColor(.purple)
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
                                            Text("Designer")
                                            Text("Developer")
                                            Text("Debussy")
                                            Text("Declarative")
                                            Text("Design")
                                            Text("Decorondum")
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
            
        }
    }
}

#Preview {
    TodoView()
}
