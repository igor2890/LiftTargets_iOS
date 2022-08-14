//
//  ShootingState.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 14.08.2022.
//

import Foundation

class ShootingState: AbstractGameState {
    weak var gameVC: GameController!
    weak var game: Game!
    
    required init(gameVC: GameController, game: Game) {
        self.gameVC = gameVC
        self.game = game
    }
    
    func begin() {
        gameVC.currentNameLabel.text = game.players[game.currentPlayerIndex].name
        gameVC.setTimer(time: 0.0)
        gameVC.startTimer()
        
        gameVC.greenButton.setTitle("Next", for: .normal)
        gameVC.greenButton.isEnabled = true
        gameVC.yellowButton.setTitle("Pause", for: .normal)
        gameVC.yellowButton.isEnabled = true
        gameVC.redButton.setTitle("Stop", for: .normal)
        gameVC.redButton.isEnabled = true
    }
    
    func greenButtonTapped() {
        game.next()
    }
    
    func yellowButtonTapped() {
        game.pause()
    }
    
    func redButtonTapped() {
        game.pause()
    }
}
