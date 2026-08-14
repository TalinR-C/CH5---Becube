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
    let philosophy: String
    let info: SkillInfo
}

struct SkillInfo: Codable{
    let what: String
    let how: String
    let when: String
    let why: String
}
