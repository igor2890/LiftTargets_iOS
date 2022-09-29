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
        nextPlayer()
    }
    
    func yellowButtonTapped() {
        game.state = game.pauseState
    }
    
    func redButtonTapped() {
        game.state = game.pauseState
    }
    
    func targetNotifReceive(targetNotification notif: TargetNotification) {
        game.startTimer()
        if notif.isAllUp {
            game.currentPlayer.add(session: Session(startTime: notif.timeStamp))
            return
        }
        game.currentPlayer.sessions.last?.hits = notif.targetStates.filter { $0 }.count
        if notif.isAllDown {
            game.currentPlayer.sessions.last?.endTimeStamp = notif.timeStamp
            nextPlayer()
        }
    }
    
    func gunDidShoot(player: Player) {
        if player.name == game.currentPlayer.name {
            game.currentPlayer.sessions.last?.shoots += 1
        }
        if game.isShootsLimitOn,
           let shoots = game.currentPlayer.sessions.last?.shoots,
           shoots >= game.shootsPerSession {
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) {_ in
                if let shoots = self.game.currentPlayer.sessions.last?.shoots,
                   shoots >= self.game.shootsPerSession {
                    self.nextPlayer()
                }
            }
        }
    }
    
    private func nextPlayer() {
        gameVC.playersTableView.reloadData()
        game.deviceManager.liftTargetsAndAskForStatus()
        game.stopTimer()
        game.setTimer(time: 0.0)
        game.nextPlayerAndRound()
    }
}
