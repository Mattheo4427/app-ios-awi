//
//  SessionViewModel.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import Foundation

@MainActor
class SessionViewModel: ObservableObject {
    @Published var sessions: [Session] = []
    private let endpoint = "sessions/"

    // Fetch all sessions
    func fetchSessions() async {
        do {
            let data = try await fetchData(from: endpoint)
            if let fetchedSessions: [Session] = decodeJSON(from: data, as: [Session].self) {
                self.sessions = fetchedSessions
            }
        } catch {
            print("Erreur récupération sessions:", error)
        }
    }

    // Create a new session
    func createSession(session: Session) async {
        do {
            let body = try JSONEncoder().encode(session)
            let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body)
            
            if let newSession: Session = decodeJSON(from: data, as: Session.self) {
                self.sessions.append(newSession) // Add new session to list
            }
        } catch {
            print("Erreur création session:", error)
        }
    }

    // Update an existing session
    func updateSession(session: Session) async {
        do {
            let body = try JSONEncoder().encode(session)
            let data = try await fetchData(from: "\(endpoint)/\(session.id_session)", reqMethod: "PUT", body: body)
            
            if let updatedSession: Session = decodeJSON(from: data, as: Session.self) {
                if let index = self.sessions.firstIndex(where: { $0.id_session == updatedSession.id_session }) {
                    self.sessions[index] = updatedSession // Update local list
                }
            }
        } catch {
            print("Erreur modification session:", error)
        }
    }

    // Delete a session
    func deleteSession(sessionID: Int) async {
        do {
            _ = try await fetchData(from: "\(endpoint)/\(sessionID)", reqMethod: "DELETE")
            self.sessions.removeAll { $0.id_session == sessionID } // Remove from local list
        } catch {
            print("Erreur suppression session:", error)
        }
    }
}
