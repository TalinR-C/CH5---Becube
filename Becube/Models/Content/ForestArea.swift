//
//  ForestArea.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  Immutable, decoded from JSON
//

import Foundation

struct ForestArea: Codable, Hashable {
    let id: String
    let name: String
    let copingSkillIds: [String]
    let index: Int

}
