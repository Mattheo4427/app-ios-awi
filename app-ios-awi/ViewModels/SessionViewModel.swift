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
    
    @AppStorage("authToken") private var authToken = ""
    @Published var errorMessage: String? = nil
    
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
            self.errorMessage = nil
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
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
            self.errorMessage = nil
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
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
    
    // Centralized error handling
    private func handleError(_ error: NetworkError) {
        switch error {
        case .requestFailed(let statusCode, let message):
            if statusCode == 401 {
                self.errorMessage = "Authentification nécessaire"
            } else if let backendMessage = message, !backendMessage.isEmpty {
                // Use the backend's message directly
                self.errorMessage = backendMessage
            } else {
                self.errorMessage = "Erreur serveur (\(statusCode))"
            }
        case .invalidURL:
            self.errorMessage = "URL invalide"
        case .invalidMethod:
            self.errorMessage = "Méthode invalide"
        case .noData:
            self.errorMessage = "Aucune donnée reçue"
        case .decodingError(let message):
            self.errorMessage = "Erreur de décodage: \(message)"
        }
    }
}

extension SessionViewModel {
    func dismissError() {
        DispatchQueue.main.async {
            self.errorMessage = nil
        }
    }
}
