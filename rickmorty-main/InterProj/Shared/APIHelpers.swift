//
//  APIHelpers.swift
//  InterProj
//
//  Created by Andrei Lucacel on 12/07/2026.
//

import Foundation

enum APIHelpers {
    static func id(from urlString: String) -> Int? {
        return Int(urlString.split(separator: "/").last ?? "")
    }
    
    static func ids(from urlStrings: [String]) -> [Int] {
        return urlStrings.compactMap { id(from: $0) }
    }
}
