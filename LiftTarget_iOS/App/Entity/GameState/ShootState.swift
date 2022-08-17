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
    
    required init(gameVC: GameController, game: Game) {
        self.gameVC = gameVC
        self.game = game
    }
    
    func begin() {
        gameVC.currentNameLabel.text = game.players[game.currentPlayerIndex].name
        
        gameVC.isScreenAlwaysOn = true
        
        game.startTimer()
        
        gameVC.greenButton.setTitle("Next", for: .normal)
        gameVC.greenButton.isEnabled = true
        gameVC.yellowButton.setTitle("Pause", for: .normal)
        gameVC.yellowButton.isEnabled = true
        gameVC.redButton.setTitle("Stop", for: .normal)
        gameVC.redButton.isEnabled = true
        
        game.startTimer()
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
    
    func notifReceive(targetNotification notif: TargetNotification) {
        gameVC.targetsView.setTargets(targetStates: notif.targetStates)
        if notif.isAllDown { game.bluetoothManager.sendMessageToPeripheral(msg: "+U") }
        else if notif.isAllUp { nextPlayer() }
    }
    
    private func nextPlayer() {
        game.stopTimer()
        game.setTimer(time: 0.0)
        if game.currentPlayerIndex < game.players.count - 1 {
            game.currentPlayerIndex += 1
        } else {
            game.currentPlayerIndex = 0
            game.currentRound += 1
        }
        
        if game.currentRound >= game.roundsPerSession {
            game.state = game.waitState
        } else {
            game.state = game.shootState
        }
    }
}
