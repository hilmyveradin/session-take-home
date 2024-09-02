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
        }
        .onAppear {
            // Decode Category data here...
        }
    }
}

#Preview {
    ContentView()
}
