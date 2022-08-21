//
//  Player.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 14.08.2022.
//

import Foundation

class Session {
    var shoots: Int = 0
    var hits: Int = 0
    var startTimeStamp: Int = 0
    var endTimeStamp: Int = 0
    var pauseTime: Int = 0
    var time: Double {
        return Double(endTimeStamp - startTimeStamp - pauseTime) / 1000
    }
    
    init(startTime: Int) {
        self.startTimeStamp = startTime
    }
}

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
    
    
    init(name: String) {
        self.name = name
    }
    
    func add(session: Session) {
        sessions.append(session)
    }
}
