//
//  CopingSkill.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  Immutable, decoded from JSON
//

import Foundation
import UIKit

struct CopingSkill: Codable{
    let id: String
    let index: Int
    let name: String
    let image: String
    let philosophy: String
    let info: [String: String]
}
