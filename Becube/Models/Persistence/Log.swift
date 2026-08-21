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
    var rating : Int?
    var journal : String?
    
    init(id: UUID, date: Date, copingID: String, rating: Int? = nil, journal: String? = nil) {
        self.id = id
        self.date = date
        self.copingID = copingID
        self.rating = rating
        self.journal = journal
    }
}
