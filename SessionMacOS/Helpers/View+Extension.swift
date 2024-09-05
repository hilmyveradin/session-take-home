//
//  View+Extension.swift
//  SessionMacOS
//
//  Created by Hilmy Veradin on 05/09/24.
//

// Custom ViewModifier for consistent card style
import SwiftUI

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardStyle())
    }
}
