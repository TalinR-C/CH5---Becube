//
//  ContentRepository.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  Loads + caches JSON for current locale
//

import Foundation

enum ContentType{
    case areas
    case skills
}

class ContentRepository{
    static func decodeSkill(file: String) -> [CopingSkill]{
        guard let url = Bundle.main.url(forResource: file, withExtension: nil) else {
            fatalError("Faliled to locate \(file) in bundle")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load file from \(file) from bundle")
        }
        
        let decoder = JSONDecoder()
        
        let loadedFile = try? decoder.decode([CopingSkill].self, from: data)
        return loadedFile!

    }
    
    static func decodeArea(file: String) -> [ForestArea] {
        guard let url = Bundle.main.url(forResource: file, withExtension: nil) else {
            fatalError("Faliled to locate \(file) in bundle")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load file from \(file) from bundle")
        }
        
        let decoder = JSONDecoder()
        
        let loadedFile = try? decoder.decode([ForestArea].self, from: data)
        return loadedFile!
        
    }
    
    static let skills = decodeSkill(file: "skills_en")
    static let areas = decodeArea(file: "areas")

}



    

