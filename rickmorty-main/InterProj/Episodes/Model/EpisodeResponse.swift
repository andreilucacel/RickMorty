//
//  EpisodeResponse.swift
//  InterProj
//
//  Created by Andrei Lucacel on 18/06/2026.
//

import Foundation

struct EpisodeResponse: Decodable {
    let info: Info
    let results: [Episode]
}

struct Info: Decodable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}

struct Episode: Decodable {
    let id: Int
    let name: String
    let airDate: String
    let episode: String
    let characters: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case airDate = "air_date"
        case episode
        case characters
    }
}
