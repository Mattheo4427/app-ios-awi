//
//  SessionViewModel.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import Foundation
import SwiftUI

@MainActor
class SessionViewModel: ObservableObject {
    @Published var sessions: [Session] = []
    private let endpoint = "sessions/"
    
    // Add the token from AppStorage like in ManagerViewModel
    @AppStorage("authToken") private var authToken = ""

    // Fetch all sessions
    func fetchSessions() async {
        do {
            let data = try await fetchData(from: endpoint, reqMethod: "GET", token: authToken)
            
            let decoder = JSONDecoder()
            // Create the formatter inside the closure to avoid capture issues.
            decoder.dateDecodingStrategy = .custom { decoder -> Date in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let date = formatter.date(from: dateString) {
                    return date
                }
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
            }

            if let decodedSessions: [Session] = decodeJSON(from: data, as: [Session].self) {
                self.sessions = decodedSessions
            }
        } catch {
            print("Failed to fetch sessions: \(error)")
        }
    }

    // Create a new session
    func createSession(session: Session) async {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let body = try encoder.encode(session)
            let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body, token: authToken)
            
            if let newSession: Session = decodeJSON(from: data, as: Session.self) {
                self.sessions.append(newSession)
            }
        } catch {
            print("Erreur création session:", error)
        }
    }

    // Update an existing session
    func updateSession(session: Session) async {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let body = try encoder.encode(session)
            let data = try await fetchData(from: "\(endpoint)update/\(session.id_session)", reqMethod: "PUT", body: body, token: authToken)
            
            if let updatedSession: Session = decodeJSON(from: data, as: Session.self) {
                if let index = self.sessions.firstIndex(where: { $0.id_session == updatedSession.id_session }) {
                    self.sessions[index] = updatedSession
                }
            }
        } catch {
            print("Erreur modification session:", error)
        }
    }

    // Delete a session
    func deleteSession(sessionID: Int) async {
        do {
            _ = try await fetchData(from: "\(endpoint)delete/\(sessionID)", reqMethod: "DELETE", token: authToken)
            self.sessions.removeAll { $0.id_session == sessionID } // Remove from local list
        } catch {
            print("Erreur suppression session:", error)
        }
    }
}	
