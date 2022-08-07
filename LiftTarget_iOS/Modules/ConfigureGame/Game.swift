//
//  Game.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 07.08.2022.
//

import Foundation

struct Session {
    var shoots: Int
    var hits: Int
    var time: Double
}

struct Player {
    let name: String
    
    private var sessions: [Session] = []
    
    init(name: String) {
        self.name = name
    }
    
    mutating func add(session: Session) {
        sessions.append(session)
    }
    
    func getSessions() -> [Session] {
        sessions
    }
}

class Game {
    let id = UUID()
    let players: [Player]
    let shootsPerSession: Int
    let roundsCount: Int
    
    var currentRound: Int = 0
    var currentPlayer: Player?
    
    init(players: [Player], shootsPerSession: Int, roundsCount: Int) {
        self.players = players
        self.shootsPerSession = shootsPerSession
        self.roundsCount = roundsCount
        self.currentPlayer = self.players.first
    }
}
