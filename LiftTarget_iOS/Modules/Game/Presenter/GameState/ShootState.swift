//
//  ShootState.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 14.08.2022.
//

import Foundation

class ShootState: AbstractGameState {
    weak var gameVC: GameController!
    weak var game: Game!
    
    var timer: Timer?
    
    required init(gameVC: GameController, game: Game) {
        self.gameVC = gameVC
        self.game = game
    }
    
    func begin() {
        gameVC.playersTableView.reloadData()
        
        gameVC.currentNameLabel.text = game.currentPlayer.name
        gameVC.currentRoundLabel.text = "Round: \(game.currentRound + 1)"
        
        gameVC.isScreenAlwaysOn = true
        
        gameVC.greenButton.setTitle("Next", for: .normal)
        gameVC.greenButton.isEnabled = true
        gameVC.yellowButton.setTitle("Pause", for: .normal)
        gameVC.yellowButton.isEnabled = true
        gameVC.redButton.setTitle("Stop", for: .normal)
        gameVC.redButton.isEnabled = true
    }
    
    func greenButtonTapped() {
        game.deviceManager.renewTarget()
    }
    
    func yellowButtonTapped() {
        game.state = game.pauseState
    }
    
    func redButtonTapped() {
        game.state = game.pauseState
    }
    
    func targetNotifReceive(targetNotification notif: TargetNotification) {
        switch notif.type {
        case .start:
            gameVC.playersTableView.reloadData()
            
            game.stopTimer()
            game.setTimer(time: 0.0)
            game.startTimer()
            
            game.currentPlayer.add(session: Session(startTime: notif.timeStamp))
        case .notif:
            break
        case .end:
            timer?.invalidate()
            game.currentPlayer.sessions.last?.endTimeStamp = notif.timeStamp
            game.stopTimer()
            game.nextPlayerAndRound()
        }
    }
    
    func gunDidShoot(player: Player) {
        if player.name == game.currentPlayer.name {
            game.currentPlayer.sessions.last?.shoots += 1
            
            if game.isShootsLimitOn,
               let shoots = game.currentPlayer.sessions.last?.shoots,
               shoots >= game.shootsPerSession {
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) {_ in
                    self.game.deviceManager.renewTarget()
                }
            }
        }
    }
}
