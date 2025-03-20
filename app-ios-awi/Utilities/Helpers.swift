//
//  Helpers.swift
//  app-ios-awi
//
//  Created by etud on 15/03/2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidMethod
    case requestFailed(statusCode: Int)
    case noData
    case decodingError(String)
}

func fetchData(from urlPath: String, reqMethod: String = "GET", body: Data? = nil, token: String? = nil) async throws -> Data? {

    let urlBack = "https://devmobile-backend-a6e37be12111.herokuapp.com/"
    
    guard let url = URL(string: urlBack + urlPath) else {
        print("🔴 Network Error: Invalid URL - \(urlBack + urlPath)")
        throw NetworkError.invalidURL
    }
    
    var request = URLRequest(url: url)
    
    let validMethods = ["GET", "POST", "PUT", "DELETE"]
    
    guard validMethods.contains(reqMethod.uppercased()) else {
        print("🔴 Network Error: Invalid method - \(reqMethod)")
        throw NetworkError.invalidMethod
    }
    
    request.httpMethod = reqMethod.uppercased()
    request.httpBody = body
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Add Authorization header if token is provided
    if let token = token, !token.isEmpty {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("🔑 Using authentication token for request")
    }
    
    print("🔵 Network Request: \(reqMethod) \(url.absoluteString)")
    if let body = body, let bodyString = String(data: body, encoding: .utf8) {
        print("📦 Request Body: \(bodyString)")
    }
    
    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("🔴 Network Error: Invalid response type")
            throw NetworkError.requestFailed(statusCode: 0)
        }
        
        print("🟢 Response Status: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
            if let responseString = String(data: data, encoding: .utf8) {
                print("📦 Response Data: \(responseString)")
            }
            return data
        } else {
            if let responseString = String(data: data, encoding: .utf8) {
                print("🔴 Error Response: \(responseString)")
            }
            throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
        }
    } catch {
        print("🔴 Network Error: \(error.localizedDescription)")
        throw error
    }
}

func decodeJSON<T: Decodable>(from data: Data?, as type: T.Type) -> T? {
    guard let data = data else {
        print("🔴 Decoding Error: No data provided")
        return nil
    }
    
    let decoder = JSONDecoder()
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    decoder.dateDecodingStrategy = .custom { decoder -> Date in
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        if let date = formatter.date(from: dateString) {
            return date
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
    }
    
    do {
        let result = try decoder.decode(T.self, from: data)
        print("🟢 Successfully decoded \(String(describing: T.self))")
        return result
    } catch {
        print("🔴 Decoding Error for \(String(describing: T.self)): \(error)")
        if let dataString = String(data: data, encoding: .utf8) {
            print("📦 Raw data that failed to decode: \(dataString)")
        }
        return nil
    }
}
