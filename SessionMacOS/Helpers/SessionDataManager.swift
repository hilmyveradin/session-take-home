//
//  SessionDataManager.swift
//  SessionMacOS
//
//  Created by Hilmy Veradin on 03/09/24.
//

import Foundation

// MARK: - UserDefaults Singleton
class SessionDataManager {
    static let shared = SessionDataManager()
    private let defaults = UserDefaults.standard
    private let sessionsKey = "savedSessions"
    
    private init() {}
    
    func loadSessions() -> [Session] {
        if let savedData = defaults.data(forKey: sessionsKey),
           let decodedSessions = try? JSONDecoder().decode([Session].self, from: savedData) {
            return decodedSessions
        } else {
            // Load from JSON file for the first time
            let sessions = loadFromJSON()
            saveSessions(sessions)
            return sessions
        }
    }
    
    func saveSessions(_ sessions: [Session]) {
        if let encodedData = try? JSONEncoder().encode(sessions) {
            defaults.set(encodedData, forKey: sessionsKey)
        }
    }
    
    private func loadFromJSON() -> [Session] {
        guard let url = Bundle.main.url(forResource: "MockData", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let sessions = try? JSONDecoder().decode([Session].self, from: data) else {
            print("Failed to load MockData.json")
            return []
        }
        return sessions
    }
    
    func updateSession(_ updatedSession: Session) {
        var sessions = loadSessions()
        if let index = sessions.firstIndex(where: { $0.id == updatedSession.id }) {
            sessions[index] = updatedSession
            saveSessions(sessions)
        }
    }
}
