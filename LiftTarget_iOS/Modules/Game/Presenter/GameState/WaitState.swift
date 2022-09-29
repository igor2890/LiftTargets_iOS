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
        game.reset()
        game.stopTimer()
        game.setTimer(time: 0.0)
        
        gameVC.currentNameLabel.text = ""
        gameVC.currentRoundLabel.text = "Round: "
        gameVC.isScreenAlwaysOn = false
        
        gameVC.greenButton.setTitle("Start", for: .normal)
        gameVC.greenButton.isEnabled = true
        gameVC.yellowButton.setTitle("Ready", for: .normal)
        gameVC.yellowButton.isEnabled = false
        gameVC.redButton.setTitle("Exit", for: .normal)
        gameVC.redButton.isEnabled = true
        
        if game.isEnd {
            let result = GameReferee.judge(players: game.players)
            gameVC.showOk(title: "Game end", message: result) {
                self.game.players.forEach {
                    $0.sessions = []
                }
            }
        }
    }
    
    func greenButtonTapped() {
        game.state = game.shootState
        game.deviceManager.liftTargetsAndAskForStatus()
    }
    
    func yellowButtonTapped() { }

    func redButtonTapped() {
        gameVC.dismiss(animated: true)
    }
    
    func targetNotifReceive(targetNotification notif: TargetNotification) {}
    
    func gunDidShoot(player: Player) {}
}
