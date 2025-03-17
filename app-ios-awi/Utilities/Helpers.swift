//
//  Helpers.swift
//  app-ios-awi
//
//  Created by etud on 15/03/2025.
//

import Foundation

/* USES for GET, POST, PUT, DELETE
 
 fetchData(from: "https://api.example.com/items") { data in
     // Handle response
 }
 
 let jsonData = try? JSONEncoder().encode(["name": "John Doe"])
 fetchData(from: "https://api.example.com/users", method: "POST", body: jsonData) { data in
     // Handle response
 }

 let updatedData = try? JSONEncoder().encode(["name": "Updated Name"])
 fetchData(from: "https://api.example.com/users/1", method: "PUT", body: updatedData) { data in
     // Handle response
 }

 fetchData(from: "https://api.example.com/users/1", method: "DELETE") { data in
     // Handle response
 }

 */
func fetchData(from urlString: String, method: String = "GET", body: Data? = nil) async throws -> Data? {
    guard let url = URL(string: urlString) else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.httpBody = body
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let (data, _) = try await URLSession.shared.data(for: request)
    return data
}

func decodeJSON<T: Decodable>(from data: Data?, as type: T.Type) -> T? {
    guard let data = data else { return nil }
    
    let decoder = JSONDecoder()
    do {
        return try decoder.decode(T.self, from: data)
    } catch {
        print("Decoding error: \(error)")
        return nil
    }
}

