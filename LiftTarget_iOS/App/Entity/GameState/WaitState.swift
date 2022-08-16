//
//  WaitState.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 14.08.2022.
//

import Foundation

class WaitState: AbstractGameState {
    weak var gameVC: GameController!
    weak var game: Game!
    
    required init(gameVC: GameController, game: Game) {
        self.gameVC = gameVC
        self.game = game
    }
    
    func begin() {
        gameVC.currentNameLabel.text = ""
        gameVC.stopTimer()
        gameVC.setTimer(time: 0.0)
        
        
        gameVC.greenButton.setTitle("Start", for: .normal)
        gameVC.greenButton.isEnabled = true
        gameVC.yellowButton.setTitle("Ready", for: .normal)
        gameVC.yellowButton.isEnabled = false
        gameVC.redButton.setTitle("Exit", for: .normal)
        gameVC.redButton.isEnabled = true
        
    }
    
    func greenButtonTapped() {
        game.start()
    }
    
    func yellowButtonTapped() {
        
    }

    func redButtonTapped() {
        game.exit()
    }
}
