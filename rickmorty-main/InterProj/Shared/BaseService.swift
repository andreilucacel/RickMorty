//
//  BaseService.swift
//  InterProj
//
//  Created by Andrei Lucacel on 25/06/2026.
//

import Foundation
 
class BaseService {
    
    func getResponse<T: Decodable>(urlString: String) async throws -> T{
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let response = try JSONDecoder().decode(T.self, from: data)
        
        return response
    }
}
