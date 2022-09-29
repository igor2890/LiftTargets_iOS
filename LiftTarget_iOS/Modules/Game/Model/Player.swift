//
//  Player.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 14.08.2022.
//

import Foundation

class Player {
    let name: String
    var sessions: [Session] = []
    
    var totalShoots: Int {
        sessions
            .map { $0.shoots }
            .reduce(0, +)
    }
    var totalHits: Int {
        sessions
            .map { $0.hits }
            .reduce(0, +)
    }
    
    var totalTime: Double {
        sessions
            .map { $0.time }
            .reduce(0, +)
    }
    
    var totalPercent: Int {
        let shoots = totalShoots
        if shoots == 0 {
            return 100
        } else {
            return Int(Double(totalHits) / Double(shoots) * 100)
        }
    }
    
    
    init(name: String) {
        self.name = name
    }
    
    func add(session: Session) {
        sessions.append(session)
    }
}
