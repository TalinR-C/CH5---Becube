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
        
        do {
        let loadedFile = try decoder.decode([CopingSkill].self, from: data)
        return loadedFile
        
        } catch let DecodingError.keyNotFound(key, context) {
            fatalError("Failed to decode: Missing key '\(key.stringValue)' - \(context.debugDescription)")
        } catch let DecodingError.typeMismatch(type, context) {
            fatalError("Failed to decode: Type mismatch for '\(type)' - \(context.debugDescription)")
        } catch let DecodingError.valueNotFound(type, context) {
            fatalError("Failed to decode: Missing value for '\(type)' - \(context.debugDescription)")
        } catch let DecodingError.dataCorrupted(context) {
            fatalError("Failed to decode: Data corrupted - \(context.debugDescription)")
        } catch {
            fatalError("Failed to decode \(file): \(error.localizedDescription)")
        }

    }
    
    static func decodeArea(file: String) -> [ForestArea]{
        guard let url = Bundle.main.url(forResource: file, withExtension: nil) else {
            fatalError("Faliled to locate \(file) in bundle")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load file from \(file) from bundle")
        }
        
        let decoder = JSONDecoder()
        
        do {
        let loadedFile = try decoder.decode([ForestArea].self, from: data)
        return loadedFile
        
        } catch let DecodingError.keyNotFound(key, context) {
            fatalError("Failed to decode: Missing key '\(key.stringValue)' - \(context.debugDescription)")
        } catch let DecodingError.typeMismatch(type, context) {
            fatalError("Failed to decode: Type mismatch for '\(type)' - \(context.debugDescription)")
        } catch let DecodingError.valueNotFound(type, context) {
            fatalError("Failed to decode: Missing value for '\(type)' - \(context.debugDescription)")
        } catch let DecodingError.dataCorrupted(context) {
            fatalError("Failed to decode: Data corrupted - \(context.debugDescription)")
        } catch {
            fatalError("Failed to decode \(file): \(error.localizedDescription)")
        }

    }
    
    
    static let skills = decodeSkill(file: "skills_en.json")
    static let areas = decodeArea(file: "areas.json")

}

extension ContentRepository {
    /// Routes carry ids; these turn an id back into content at the one place
    /// that needs it. Linear over 16 items — a dictionary would be premature.
    static func skill(id: String) -> CopingSkill? {
        skills.first { $0.id == id }
    }

    static func area(id: String) -> ForestArea? {
        areas.first { $0.id == id }
    }
}
