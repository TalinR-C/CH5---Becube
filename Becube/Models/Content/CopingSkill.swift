//
//  CopingSkill.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  Immutable, decoded from JSON
//

import Foundation

struct CopingSkill: Codable{
    let id: String
    let index: Int
    let name: String
    let image: String
    let plantPhilosophy: String
    let info: [String: String]
}
