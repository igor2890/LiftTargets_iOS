//
//  PauseState.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 14.08.2022.
//

import Foundation

import Foundation

class PauseState: AbstractGameState {
    weak var gameVC: GameController!
    weak var game: Game!

    required init(gameVC: GameController, game: Game) {
        self.gameVC = gameVC
        self.game = game
    }
    
    func begin() {
        game.stopTimer()

        gameVC.isScreenAlwaysOn = false
        
        gameVC.greenButton.setTitle("Resume", for: .normal)
        gameVC.greenButton.isEnabled = true
        gameVC.yellowButton.setTitle("Paused", for: .normal)
        gameVC.yellowButton.isEnabled = false
        gameVC.redButton.setTitle("Stop", for: .normal)
        gameVC.redButton.isEnabled = true
    }
    
    func greenButtonTapped() {
        game.state = game.shootState
    }
    
    func yellowButtonTapped() {
    }
    
    func redButtonTapped() {
        game.state = game.waitState
    }
    
    func notifReceive(targetNotification notif: TargetNotification) {
        gameVC.targetsView.setTargets(targetStates: notif.targetStates)
    }
}
