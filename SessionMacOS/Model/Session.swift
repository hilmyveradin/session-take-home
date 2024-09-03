//
//  Session.swift
//  SessionMacOS
//
//  Created by Hilmy Veradin on 03/09/24.
//

import Foundation

struct Session: Codable, Identifiable {
    var id: String
    var name: String
    var focus: [String]
    var todo: [String]
    var color: String
    
    enum CodingKeys: String, CodingKey {
        case focus, todo, color
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dict = try container.decode([String: SessionContent].self)
        guard let (key, value) = dict.first else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Empty dictionary")
        }
        
        self.id = key
        self.name = key
        self.focus = value.focus
        self.todo = value.todo
        self.color = value.color
    }
}

// This is a private struct used only for decoding
private struct SessionContent: Codable {
    let focus: [String]
    let todo: [String]
    let color: String
}

