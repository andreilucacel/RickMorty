//
//  CharacterService.swift
//  InterProj
//
//  Created by Andrei Lucacel on 18/06/2026.
//

import UIKit

final class CharacterService: BaseService {
    //    func getCharacters(urlString: String, completionHandler: @escaping (CharacterResponse) -> Void) throws  {
    //        guard let url = URL(string: urlString) else {
    //            throw URLError(.badURL)
    //        }
    //
    //        var request = URLRequest(url: url)
    //        request.httpMethod = "GET"
    //        let task = URLSession.shared.dataTask(with: request) { data, _, error in
    //            guard let data else {
    //                if let error = error {
    //                    print(error.localizedDescription)
    //                }
    //                return
    //            }
    //            do {
    //                let result = try JSONDecoder().decode(CharacterResponse.self, from: data)
    //                completionHandler(result)
    //            } catch {
    //                print(error.localizedDescription)
    //            }
    //
    //        }
    //
    //        task.resume()
    //
    //        
    //    }
    
    func getCharacters(urlString: String = "https://rickandmortyapi.com/api/character") async throws -> CharacterResponse {
        
        return try await getResponse(urlString: urlString)
    }
    
    func getCharacters(status: String?, gender: String?, name: String?) async throws -> CharacterResponse {
        var components = URLComponents(string: "https://rickandmortyapi.com/api/character")!
        var queryItems: [URLQueryItem] = []
        
        if let status, !status.isEmpty {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }
        if let gender, !gender.isEmpty {
            queryItems.append(URLQueryItem(name: "gender", value: gender))
        }
        if let name, !name.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        return try await getResponse(urlString: components.url!.absoluteString)
    }
    
    func getCharacters(ids: [Int]) async throws -> [Character] {
        guard !ids.isEmpty else { return [] }
        
        let idsString = ids.map(String.init).joined(separator: ",")
        let urlString = "https://rickandmortyapi.com/api/character/\(idsString)"
        
        if ids.count == 1 {
            let character: Character = try await getResponse(urlString: urlString)
            return [character]
        } else {
            return try await getResponse(urlString: urlString)
        }
    }
}
