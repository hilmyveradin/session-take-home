//
//  DataManager.swift
//  SessionMacOS
//
//  Created by Hilmy Veradin on 04/09/24.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    private let defaults = UserDefaults.standard
    private let todosKey = "savedTodos"
    private let categoriesKey = "savedCategories"

    private init() {}

    // MARK: - Load Data

    func loadTodos() -> [Todo] {
        if let savedData = defaults.data(forKey: todosKey),
           let decodedTodos = try? JSONDecoder().decode([Todo].self, from: savedData)
        {
            return decodedTodos
        } else {
            // Load from JSON file for the first time
            let todos = loadTodosFromJSON()
            saveTodos(todos)
            return todos
        }
    }

    func loadCategories() -> [Category] {
        if let savedData = defaults.data(forKey: categoriesKey),
           let decodedCategories = try? JSONDecoder().decode([Category].self, from: savedData)
        {
            return decodedCategories
        } else {
            // Load from JSON file for the first time
            let categories = loadCategoriesFromJSON()
            saveCategories(categories)
            return categories
        }
    }

    // MARK: - Save Data

    func saveTodos(_ todos: [Todo]) {
        if let encodedData = try? JSONEncoder().encode(todos) {
            defaults.set(encodedData, forKey: todosKey)
        }
    }

    func saveCategories(_ categories: [Category]) {
        if let encodedData = try? JSONEncoder().encode(categories) {
            defaults.set(encodedData, forKey: categoriesKey)
        }
    }

    // MARK: - Load from JSON

    private func loadTodosFromJSON() -> [Todo] {
        guard let url = Bundle.main.url(forResource: "TodoData", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let todoData = try? JSONDecoder().decode(TodoData.self, from: data)
        else {
            print("Failed to load TodoData.json")
            return []
        }
        return todoData.todos
    }

    private func loadCategoriesFromJSON() -> [Category] {
        guard let url = Bundle.main.url(forResource: "CategoryData", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let categoryData = try? JSONDecoder().decode(CategoryData.self, from: data)
        else {
            print("Failed to load CategoryData.json")
            return []
        }
        return categoryData.categories
    }
}
