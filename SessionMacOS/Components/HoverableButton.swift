//
//  HoverableButton.swift
//  SessionMacOS
//
//  Created by Hilmy Veradin on 03/09/24.
//

import SwiftUI

struct HoverableButton<Content: View>: View {
    let isPriority: Bool
    let action: () -> Void
    let content: () -> Content
    
    init(isPriority: Bool, action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.isPriority = isPriority
        self.action = action
        self.content = content
    }
    
    var body: some View {
        Button(action: action) {
            content()
                .padding(8)
                .cornerRadius(5)
        }
        .buttonStyle(PlainButtonStyle())
        .allowsHitTesting(isPriority)
    }
}
