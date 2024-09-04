//
//  Category.swift
//  SessionMacOS
//
//  Created by Hilmy Veradin on 04/09/24.
//

import Foundation

// MARK: - Category Model
struct Category: Codable, Identifiable {
    let id: UUID
    let name: String
    let color: String

    enum CodingKeys: String, CodingKey {
        case name, color
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        color = try container.decode(String.self, forKey: .color)
        id = UUID()  // Generate a new UUID for each decoded category
    }
}

// Model for extract mock json data
struct CategoryData: Codable {
    var categories: [Category]
}
