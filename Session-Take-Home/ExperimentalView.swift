//
//  ExperimentalView.swift
//  Session-Take-Home
//
//  Created by Hilmy Veradin on 03/09/24.
//

import SwiftUI

/// Experimental  view using Geometry Reader
//struct ExperimentalView: View {
//    @State private var isShowingCategories = false
//    @State private var isShowingSuggestions = false
//    @State private var focusText = ""
//    
//    var body: some View {
//        GeometryReader { geometry in
//            VStack(spacing: 0) {
//                categoryHeader
//                focusTextField
//                todoList
//            }
//            .overlay(
//                Group {
//                    if isShowingCategories {
//                        categoryPopup
//                            .transition(.move(edge: .top))
//                    }
//                    if isShowingSuggestions {
//                        suggestionPopup
//                            .transition(.move(edge: .top))
//                    }
//                }
//                .alignmentGuide(.top) { _ in
//                    -geometry.safeAreaInsets.top
//                },
//                alignment: .top
//            )
//        }
//    }
//    
//    var categoryHeader: some View {
//        HStack {
//            Text("Categories")
//            Spacer()
//            Image(systemName: "chevron.down")
//        }
//        .padding()
//        .background(Color.white)
//        .onTapGesture {
//            withAnimation {
//                isShowingCategories.toggle()
//                if isShowingCategories {
//                    isShowingSuggestions = false
//                }
//            }
//        }
//    }
//    
//    var focusTextField: some View {
//        TextField("What's your focus?", text: $focusText)
//            .padding()
//            .background(Color.white)
//            .onTapGesture {
//                withAnimation {
//                    isShowingSuggestions = true
//                    isShowingCategories = false
//                }
//            }
//    }
//    
//    var todoList: some View {
//        List {
//            ForEach(0..<10) { _ in
//                HStack {
//                    Image(systemName: "square")
//                    Text("Designing interface")
//                    Spacer()
//                    Text("Categories")
//                        .font(.caption)
//                        .foregroundColor(.green)
//                }
//            }
//        }
//    }
//    
//    var categoryPopup: some View {
//        VStack {
//            List {
//                Text("Design").foregroundColor(.red)
//                Text("Programming").foregroundColor(.yellow)
//                Text("Marketing").foregroundColor(.green)
//                Text("Finance").foregroundColor(.mint)
//                Text("Support").foregroundColor(.blue)
//                Text("Sleep").foregroundColor(.purple)
//            }
//            .background(Color.white)
//            .frame(height: 200)
//        }
//        .background(Color.black.opacity(0.3))
//        .edgesIgnoringSafeArea(.all)
//        .onTapGesture {
//            withAnimation {
//                isShowingCategories = false
//            }
//        }
//    }
//    
//    var suggestionPopup: some View {
//        VStack {
//            List {
//                Text("Designer")
//                Text("Developer")
//                Text("Debussy")
//                Text("Declarative")
//                Text("Design")
//                Text("Decorondum")
//            }
//            .background(Color.white)
//            .frame(height: 200)
//        }
//        .background(Color.black.opacity(0.3))
//        .edgesIgnoringSafeArea(.all)
//        .onTapGesture {
//            withAnimation {
//                isShowingSuggestions = false
//            }
//        }
//    }
//}

/// Experimental  view using ZStack
struct ExperimentalView: View {
    @State private var isShowingCategories = false
    @State private var isShowingSuggestions = false
    @State private var focusText = ""
    
    var body: some View {
        ZStack {
            // Main todo list
            VStack {
                HStack {
                    Text("Categories")
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(Color.white)
                .onTapGesture {
                    isShowingCategories = true
                    isShowingSuggestions = false
                }
                .frame(height: 50)
                
                TextField("What's your focus?", text: $focusText)
                    .padding()
                    .background(Color.white)
                    .onTapGesture {
                        isShowingSuggestions = true
                        isShowingCategories = false
                    }
                    .frame(height: 50)
                
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
            
            if isShowingCategories {
                VStack {
                    Color.black.opacity(0.001)
                        .frame(height: 50)
                        .onTapGesture {
                            isShowingSuggestions = false
                            isShowingCategories = false
                        }
                                        List {
                                            Text("Design").foregroundColor(.red)
                                            Text("Programming").foregroundColor(.yellow)
                                            Text("Marketing").foregroundColor(.green)
                                            Text("Finance").foregroundColor(.mint)
                                            Text("Support").foregroundColor(.blue)
                                            Text("Sleep").foregroundColor(.purple)
                                        }
                                        .background(.background)
                                        .listStyle(.plain)
                    Color.black.opacity(0.001)
                        .onTapGesture {
                            isShowingSuggestions = false
                            isShowingCategories = false
                        }

                }
                .zIndex(2)
            }
            
            if isShowingSuggestions {
                VStack {
                    Color.black.opacity(0.001)
                        .frame(height: 110)
                        .onTapGesture {
                            isShowingCategories = false
                            isShowingSuggestions = false
                        }
                    
                                        List {
                                            Text("Designer")
                                            Text("Developer")
                                            Text("Debussy")
                                            Text("Declarative")
                                            Text("Design")
                                            Text("Decorondum")
                                        }
                                        .background(.background)
                                        .listStyle(.plain)
                    
                    Color.black.opacity(0.001)
                        .onTapGesture {
                            isShowingCategories = false
                            isShowingSuggestions = false
                        }
                }
                .zIndex(2)
            }
            
//            // Popup for categories
//            if isShowingCategories {
//                VStack {
//                    List {
//                        Text("Design").foregroundColor(.red)
//                        Text("Programming").foregroundColor(.yellow)
//                        Text("Marketing").foregroundColor(.green)
//                        Text("Finance").foregroundColor(.mint)
//                        Text("Support").foregroundColor(.blue)
//                        Text("Sleep").foregroundColor(.purple)
//                    }
//                    .background(Color.white)
//                    .frame(height: 200)
//                    Spacer()
//                }
//                .frame(maxHeight: .infinity)
//                .transition(.move(edge: .top))
//                .zIndex(1)
//            }
//            
//            // Popup for suggestions
//            if isShowingSuggestions {
//                VStack {
//                    List {
//                        Text("Designer")
//                        Text("Developer")
//                        Text("Debussy")
//                        Text("Declarative")
//                        Text("Design")
//                        Text("Decorondum")
//                    }
//                    .background(Color.white)
//                    .frame(height: 200)
//                    Spacer()
//                }
//                .frame(maxHeight: .infinity)
//                .transition(.move(edge: .top))
//                .zIndex(2)
//            }
        }
    }
}


#Preview {
    ExperimentalView()
}
