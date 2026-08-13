//
//  PracticeLog.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  SwiftData @Model
//

import Foundation
import SwiftData

@Model
class Log {
    var id: UUID
    var date : Date
    var copingID : String
    var score : Int?
    var journal : String?
    
    init(id: UUID, date: Date, copingID: String, score: Int? = nil, journal: String? = nil) {
        self.id = id
        self.date = date
        self.copingID = copingID
        self.score = score
        self.journal = journal
    }
}

// TODO: implement
