//
//  PauseState.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 14.08.2022.
//

import Foundation

import Foundation
import QuartzCore

class PauseState: AbstractGameState {
    weak var gameVC: GameController!
    weak var game: Game!
    private var startPauseTime: DispatchTime!

    required init(gameVC: GameController, game: Game) {
        self.gameVC = gameVC
        self.game = game
    }
    
    func begin() {
        game.stopTimer()
        startPauseTime = DispatchTime.now()

        gameVC.isScreenAlwaysOn = false
        
        gameVC.greenButton.setTitle("Resume", for: .normal)
        gameVC.greenButton.isEnabled = true
        gameVC.yellowButton.setTitle("Paused", for: .normal)
        gameVC.yellowButton.isEnabled = false
        gameVC.redButton.setTitle("Stop", for: .normal)
        gameVC.redButton.isEnabled = true
    }
    
    func greenButtonTapped() {
        let stopPauseTime = DispatchTime.now()
        let pauseTime = (stopPauseTime.uptimeNanoseconds - startPauseTime.uptimeNanoseconds) / 1000000
        if let session = game.currentPlayer.sessions.last {
            session.pauseTime += Int(pauseTime)
        }
        game.state = game.shootState
        game.startTimer()
    }
    
    func yellowButtonTapped() {}
    
    func redButtonTapped() {
        game.state = game.waitState
    }
    
    func targetNotifReceive(targetNotification notif: TargetNotification) {}
    
    func gunDidShoot(player: Player) {}
}
