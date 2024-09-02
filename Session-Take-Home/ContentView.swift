//
//  ContentView.swift
//  Session-Take-Home
//
//  Created by Hilmy Veradin on 03/09/24.
//

import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    
    @State private var selectedSuggestion: String?
    @State private var selectedCategory: Category?
    
    @State private var mockCategoryData: [CategoryData] = []
    
    var body: some View {
        
        VStack {
            TextField("Search", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            
//            if !searchText.isEmpty {
//                List(.filter { $0.lowercased().contains(searchText.lowercased()) }, id: \.self) { suggestion in
//                    Text(suggestion)
//                        .onTapGesture {
//                            selectedSuggestion = suggestion
//                            searchText = suggestion
//                        }
//                        .background(selectedSuggestion == suggestion ? Color.blue.opacity(0.3) : Color.clear)
//                }
//            } else if searchText.hasSuffix("@") {
//                List(categories) { category in
//                    HStack {
//                        Circle()
//                            .fill(category.color)
//                            .frame(width: 10, height: 10)
//                        Text(category.name)
//                    }
//                    .onTapGesture {
//                        selectedCategory = category
//                    }
//                    .background(selectedCategory?.id == category.id ? Color.blue.opacity(0.3) : Color.clear)
//                }
//            }
        }
        .onAppear {
            
        }
    }
}

#Preview {
    ContentView()
}
