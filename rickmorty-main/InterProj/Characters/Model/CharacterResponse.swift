//
//  CharacterResponse.swift
//  InterProj
//
//  Created by Andrei Lucacel on 18/06/2026.
//

import Foundation


struct CharacterResponse: Decodable {
    let info: InfoResponse
    let results: [Character]
}

struct InfoResponse: Decodable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}

struct Character: Decodable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String?
    let gender: String
    let origin: LocationRef
    let location: LocationRef
    let image: String
    let episode: [String]
}

struct LocationRef: Decodable {
    let name: String
    let url: String
}
