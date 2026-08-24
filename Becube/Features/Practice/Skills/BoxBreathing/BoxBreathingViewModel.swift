//
//  BoxBreathingViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation
import SwiftUI


enum BreathPhase: CaseIterable {
    case breatheIn, hold1, breatheOut, hold2
    
    var label: String {
        switch self {
        case .breatheIn: return "Breathe In"
        case .hold1, .hold2: return "Hold"
        case .breatheOut: return "Breathe Out"
        }
    }
}

@MainActor
@Observable
final class BoxBreathingViewModel: PracticeSession {
    
    let skillID: String
    var onComplete: (() -> Void)?
    
    //Duration and the side of the square
    let phaseDuration: Double = 4.0
    let squareSize: CGFloat = 320
    
    var currentPhase: BreathPhase = .breatheIn
    var dotPosition: CGPoint
    
    var circleScale: CGFloat = 0.5
    
    private var timer: Timer?
    private var phaseIndex = 0

    private let corners: [CGPoint]
    
    init(skillID: String){
        self.skillID = skillID
        let s = squareSize
        corners = [
            CGPoint(x: 0, y: s), // bottom-left
            CGPoint(x: 0, y: 0), // top-left
            CGPoint(x: s, y: 0), // top-right
            CGPoint(x: s, y: s), // bottom-right
        ]
        dotPosition = corners[0]
    }
    
    func start() {
        advance()
        timer = Timer.scheduledTimer(withTimeInterval: phaseDuration, repeats: true) { [weak self] _ in
            // Timer fires on the main run loop, so this is genuinely safe —
            // it's how you tell the compiler that once the class is @MainActor.
            MainActor.assumeIsolated { self?.advance() }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil

        withTransaction(Transaction(animation: nil)) {
            dotPosition = dotPosition
            circleScale = circleScale
        }
    }

    private func advance() {
        currentPhase = BreathPhase.allCases[phaseIndex] // update the label immediately
        let nextCornerIndex = (phaseIndex + 1) % corners.count // wraps back to 0 after the last corner

        withAnimation(.linear(duration: phaseDuration)) {
            dotPosition = corners[nextCornerIndex]
            
            //for the circle expanding 
            switch currentPhase {
            case .breatheIn:
                circleScale = 1.0
            case .hold1:
                circleScale = 1.0
            case .breatheOut:
                circleScale = 0.5
            case .hold2:
                circleScale = 0.5 
            }
        }

        phaseIndex = nextCornerIndex
    }
    
}


