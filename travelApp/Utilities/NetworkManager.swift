//
//  NetworkManager.swift
//  travelAppiOS
//
//  Created by Андрей Степанов on 30.08.2022.
//

import Foundation

struct NetworkManager {
    private var session = URLSession.shared

    func getNetworkData<T: Codable>(urlString: String) async throws -> T? {
        guard let url = URL(string: urlString) else { print("URL is invalid"); return nil }
        do {
            let (data, _) = try await session.data(from: url)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        return nil
    }
}

