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
    private(set) var shootsPerSession: Int = 0
    private(set) var roundsPerSession: Int = 0
    
    var currentRound: Int = 0
    var currentPlayer: Player?
    
    init(players: [Player], settings: [Setting]) {
        self.players = players
        if let roundCountSetting = settings.first(where: { $0.type == .rounds }) {
            self.roundsPerSession = roundCountSetting.values[roundCountSetting.selectedIndex]
        }

        if let shootsCountSession = settings.first(where: { $0.type == .shoots }) {
            self.shootsPerSession = shootsCountSession.values[shootsCountSession.selectedIndex]
        }
        
        self.currentPlayer = self.players.first
    }
}
