//
//  PracticeKind.swift
//  Becube
//
//  Created by Ni Ketut Lela Berliani on 20/08/26.
//

enum PracticeKind {
    case boxBreathing
    // add one case here each time a new skill gets a real interactive practice built

    init?(skillID: String) {
        switch skillID {
        case "box_breathing":
            
            self = .boxBreathing
        default:
            return nil // no interactive practice exists yet for this skill — handled gracefully below
        }
    }
}
