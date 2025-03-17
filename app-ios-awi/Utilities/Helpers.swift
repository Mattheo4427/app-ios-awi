//
//  Helpers.swift
//  app-ios-awi
//
//  Created by etud on 15/03/2025.
//

import Foundation


func fetchData(from urlPath: String, reqMethod: String = "GET", body: Data? = nil) async throws -> Data? {
    let urlBack = "http://mdaf-awibackend.cluster-ig4.igpolytech.fr/"
    
    guard let url = URL(string: urlBack + urlPath) else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    
    let validMethods = ["GET", "POST", "PUT", "DELETE"]
    
    guard validMethods.contains(reqMethod.uppercased()) else {
            throw URLError(.badServerResponse)
    }
    
    request.httpMethod = reqMethod.uppercased()
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

