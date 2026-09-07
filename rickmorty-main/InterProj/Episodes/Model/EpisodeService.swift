//
//  EpisodeService.swift
//  InterProj
//
//  Created by Andrei Lucacel on 18/06/2026.
//

import Foundation

final class EpisodeService: BaseService {
    
    func getEpisodes(urlString: String) async throws -> EpisodeResponse{
        
        return try await getResponse(urlString: urlString)
    }
    
    func getEpisodes(name: String?) async throws -> EpisodeResponse {
        var components = URLComponents(string: "https://rickandmortyapi.com/api/episode")!
        if let name, !name.isEmpty {
            components.queryItems = [URLQueryItem(name: "name", value: name)]
        }
        return try await getResponse(urlString: components.url!.absoluteString)
    }
    
    func getEpisodes(ids: [Int]) async throws -> [Episode] {
        guard !ids.isEmpty else { return [] }
        
        let idsString = ids.map(String.init).joined(separator: ",")
        let urlString = "https://rickandmortyapi.com/api/episode/\(idsString)"
        
        if ids.count == 1 {
            let episode: Episode = try await getResponse(urlString: urlString)
            return [episode]
        } else {
            return try await getResponse(urlString: urlString)
        }
    }

}
