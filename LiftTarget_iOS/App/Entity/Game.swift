//
//  Game.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 07.08.2022.
//

import Foundation

class Game {
    weak var gameVC: GameController!
    weak var bluetoothManager: BluetoothManager!
    
    var state: AbstractGameState! {
        didSet {
            state.begin()
        }
    }
    
    var waitState: WaitState!
    var shootState: ShootState!
    var pauseState: PauseState!
    
    var timer: Timer?
    var timerCount = 0.0
    let timerInterval = 0.1
    
    let id = UUID()
    let players: [Player]

    private var shootsPerSession: Int = 0
    var roundsPerSession: Int = 0
    private var timerLimit: Int = 0
    
    var currentRound: Int = 0
    var currentPlayerIndex: Int = 0
    
    //MARK: Init
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
        waitState = WaitState(gameVC: gameVC, game: self)
        shootState = ShootState(gameVC: gameVC, game: self)
        pauseState = PauseState(gameVC: gameVC, game: self)
        state = waitState
    }
    
    //MARK: Buttons Taps Handlers
    func greenButtonTapped() {
        state.greenButtonTapped()
    }
    
    func yellowButtonTapped() {
        state.yellowButtonTapped()
    }

    func redButtonTapped() {
        state.redButtonTapped()
    }

    //MARK: Timer
    func setTimer(time: Double) {
        timerCount = time
        gameVC.timerLabel.text = String(format: "%.1f", timerCount)
    }
    
    func startTimer() {
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
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc
    private func timerFires() {
        setTimer(time: timerCount + timerInterval)
    }
}

//MARK: BluetoothWatcher
extension Game: BluetoothWatcher {
    func receiveFromTarget(notification: TargetNotification) {
        state.notifReceive(targetNotification: notification)
        print(notification.timeStamp)
    }
    
    func receiveError(msg: String) {
        print(msg)
    }
}
