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
        game.currentPlayerIndex = 0
        game.currentRound = 0
        
        game.stopTimer()
        game.setTimer(time: 0.0)
        
        gameVC.currentNameLabel.text = ""
        gameVC.isScreenAlwaysOn = false
        
        gameVC.greenButton.setTitle("Start", for: .normal)
        gameVC.greenButton.isEnabled = true
        gameVC.yellowButton.setTitle("Ready", for: .normal)
        gameVC.yellowButton.isEnabled = false
        gameVC.redButton.setTitle("Exit", for: .normal)
        gameVC.redButton.isEnabled = true
        
    }
    
    func greenButtonTapped() {
        game.bluetoothManager.sendMessageToPeripheral(msg: "+U")
    }
    
    func yellowButtonTapped() {
        
    }

    func redButtonTapped() {
        gameVC.dismiss(animated: true)
    }
    
    func notifReceive(targetNotification notif: TargetNotification) {
        if notif.isAllUp { game.state = game.shootState }
        gameVC.targetsView.setTargets(targetStates: notif.targetStates)
    }
}
