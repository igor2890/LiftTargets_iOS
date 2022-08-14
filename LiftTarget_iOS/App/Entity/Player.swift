//
//  Player.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 14.08.2022.
//

import Foundation

struct Session {
    var shoots: Int
    var hits: Int
    var time: Double
}

class Player {
    let name: String
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
    
    private var sessions: [Session] = []
    
    init(name: String) {
        self.name = name
    }
    
    func add(session: Session) {
        sessions.append(session)
    }
    
    func getSessions() -> [Session] {
        sessions
    }
}
