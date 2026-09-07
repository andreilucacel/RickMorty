//
//  CharacterFilter.swift
//  InterProj
//
//  Created by Andrei Lucacel on 12/07/2026.
//

import Foundation

struct CharacterFilter {
    var status: String?  
    var gender: String?
    
    var isEmpty: Bool {
        return status == nil && gender == nil
    }
}
