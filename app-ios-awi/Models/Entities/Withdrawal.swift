//
//  Withdrawal.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import Foundation
import ObjectiveC  // Add this import for objc_* functions

struct Withdrawal: Identifiable, Codable {
    let id_recover: String
    let date: Date
    let amount: Double
    let id_seller: String
    let id_session: Int
    let id_manager: String?
    let games_recovered: [GamesWithdrawed]
    
    var id: String { id_recover }
    
    enum CodingKeys: String, CodingKey {
        case id_recover, date, amount, id_seller, id_session, id_manager, games_recovered
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id_recover = try container.decode(String.self, forKey: .id_recover)
        
        // Properly decode date string to Date
        if let dateString = try container.decodeIfPresent(String.self, forKey: .date) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            if let parsedDate = formatter.date(from: dateString) {
                date = parsedDate
            } else {
                date = Date() // Fallback to current date if parsing fails
            }
        } else {
            date = Date() // Default to current date if no date provided
        }
        
        // Handle amount which might be a String or Double in the JSON
        if let amountString = try? container.decode(String.self, forKey: .amount) {
            amount = Double(amountString) ?? 0.0
        } else {
            amount = try container.decode(Double.self, forKey: .amount)
        }
        
        id_seller = try container.decode(String.self, forKey: .id_seller)
        id_session = try container.decode(Int.self, forKey: .id_session)
        id_manager = try container.decodeIfPresent(String.self, forKey: .id_manager)
        games_recovered = try container.decode([GamesWithdrawed].self, forKey: .games_recovered)
    }
    
    // Custom init for creating a new withdrawal
    init(id_recover: String, date: Date, amount: Double, id_seller: String, id_session: Int, id_manager: String?, games_recovered: [GamesWithdrawed]) {
        self.id_recover = id_recover
        self.date = date
        self.amount = amount
        self.id_seller = id_seller
        self.id_session = id_session
        self.id_manager = id_manager
        self.games_recovered = games_recovered
    }
}

// Define GamesWithdrawed without the tags property
struct GamesWithdrawed: Codable, Hashable {
    var id_game: Int
    var quantity: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id_game)
    }
    
    static func == (lhs: GamesWithdrawed, rhs: GamesWithdrawed) -> Bool {
        lhs.id_game == rhs.id_game
    }
}

// Create a separate class to store tags
// This approach avoids the issue with associated objects and structs
class GameTagsStorage {
    static var shared = GameTagsStorage()
    private var tagsMap: [ObjectIdentifier: [String]] = [:]
    
    func setTags(_ tags: [String]?, for game: GamesWithdrawed) {
        let id = ObjectIdentifier(game as AnyObject)
        tagsMap[id] = tags
    }
    
    func getTags(for game: GamesWithdrawed) -> [String]? {
        let id = ObjectIdentifier(game as AnyObject)
        return tagsMap[id]
    }
    
    func clearTags() {
        tagsMap.removeAll()
    }
}