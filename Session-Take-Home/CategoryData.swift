//
//  CategoryData.swift
//  Session-Take-Home
//
//  Created by Hilmy Veradin on 03/09/24.
//

import Foundation

struct Category: Codable, Identifiable {
    let id: String
    let name: String
    let focus: [String]
    let list: [String]
    let color: String
    
    enum CodingKeys: String, CodingKey {
        case focus, list, color
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dict = try container.decode([String: CategoryContent].self)
        guard let (key, value) = dict.first else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Empty dictionary")
        }
        
        self.id = key
        self.name = key
        self.focus = value.focus
        self.list = value.list
        self.color = value.color
    }
}

// This is a private struct used only for decoding
private struct CategoryContent: Codable {
    let focus: [String]
    let list: [String]
    let color: String
}
