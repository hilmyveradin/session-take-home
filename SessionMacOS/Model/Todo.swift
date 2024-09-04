//
//  Todo.swift
//  SessionMacOS
//
//  Created by Hilmy Veradin on 04/09/24.
//
import Foundation

struct Todo: Codable, Identifiable {
    let id: UUID
    let name: String
    let category: Category

    enum CodingKeys: String, CodingKey {
        case name, category
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(Category.self, forKey: .category)
        id = UUID()  // Generate a new UUID for each decoded todo
    }

    init(id: UUID = UUID(), name: String, category: Category) {
        self.id = id
        self.name = name
        self.category = category
    }
}

struct TodoData: Codable {
    var todos: [Todo]
}
