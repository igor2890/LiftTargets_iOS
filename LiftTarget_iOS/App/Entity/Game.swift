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
    
    var timer: Timer?
    var timerCount = 0.0
    let timerInterval = 0.1
    
    let id = UUID()
    let players: [Player]

    private(set) var shootsPerSession: Int = 0
    private(set) var roundsPerSession: Int = 0
    private(set) var timerLimit: Int = 0
    
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
        
        if let timerLimit = settings.first(where: { $0.type == .timeLimit }) {
            self.timerLimit = timerLimit.values[timerLimit.selectedIndex]
        }
        
        self.gameVC = gameVC
    }
    
    func configure() {
        state = WaitState(gameVC: gameVC, game: self)
        state.begin()
    }
    
    func start() {
        setTimer(time: 0.0)
        startTimer()
        gameVC.isScreenAlwaysOn = true
    }
    
    func pause() {
        stopTimer()
        gameVC.isScreenAlwaysOn = false
    }
    
    func resume() {
        startTimer()
        gameVC.isScreenAlwaysOn = true
    }
    
    func next() {
        stopTimer()
        setTimer(time: 0.0)
        startTimer()
    }
    
    func stop() {
        stopTimer()
        setTimer(time: 0.0)
        gameVC.isScreenAlwaysOn = false
    }
    
    func exit() {
        stopTimer()
        setTimer(time: 0.0)
        gameVC.isScreenAlwaysOn = false
    }

    private func setTimer(time: Double) {
        timerCount = time
        gameVC.timerLabel.text = String(format: "%.1f", timerCount)
    }
    
    private func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(
                timeInterval: timerInterval,
                target: self,
                selector: #selector(timerFires),
                userInfo: nil,
                repeats: true
            )
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc
    private func timerFires() {
        setTimer(time: timerCount + timerInterval)
    }
}

extension Game: BluetoothWatcher {
    func receiveFromTarget(notification: TargetNotification) {
        gameVC.targetsView.setTargets(targetStates: notification.targetStates)
        print(notification.timeStamp)
    }
    
    func receiveError(msg: String) {
        print(msg)
    }
}
