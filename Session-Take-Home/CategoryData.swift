//
//  CategoryData.swift
//  Session-Take-Home
//
//  Created by Hilmy Veradin on 03/09/24.
//

import SwiftUI

struct CategoryData: Codable, Identifiable {
    let id: String
    let category: Category
    
    enum CodingKeys: String, CodingKey {
        case id
        case category
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dict = try container.decode([String: Category].self)
        guard let (key, value) = dict.first else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Empty dictionary")
        }
        self.id = key
        self.category = value
    }
}

struct Category: Codable {
    let focus: [String]
    let list: [String]
    let color: String
}
