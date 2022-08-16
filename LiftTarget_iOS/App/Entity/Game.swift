//
//  Game.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 07.08.2022.
//

import Foundation

class Game {
    weak var gameVC: GameController!
    private(set) var state: AbstractGameState!
    
    let id = UUID()
    let players: [Player]

    private(set) var shootsPerSession: Int = 0
    private(set) var roundsPerSession: Int = 0
    
    var currentRound: Int = 0
    var currentPlayerIndex: Int = 0
    
    init(gameVC: GameController, players: [Player], settings: [Setting]) {
        self.players = players
        if let roundCountSetting = settings.first(where: { $0.type == .rounds }) {
            self.roundsPerSession = roundCountSetting.values[roundCountSetting.selectedIndex]
        }

        if let shootsCountSession = settings.first(where: { $0.type == .shoots }) {
            self.shootsPerSession = shootsCountSession.values[shootsCountSession.selectedIndex]
        }
        
        self.gameVC = gameVC
    }
    
    func configure() {
        state = WaitState(gameVC: gameVC, game: self)
        state.begin()
    }
    
    func start() {
        gameVC.startTimer()
    }
    
    func pause() {
        gameVC.stopTimer()
    }
    
    func resume() {
        gameVC.startTimer()
    }
    
    func next() {
        gameVC.stopTimer()
        gameVC.setTimer(time: 0.0)
        gameVC.startTimer()
    }
    
    func stop() {
        gameVC.stopTimer()
        gameVC.setTimer(time: 0.0)
    }
    
    func exit() {
        gameVC.stopTimer()
        gameVC.setTimer(time: 0.0)
    }
}
