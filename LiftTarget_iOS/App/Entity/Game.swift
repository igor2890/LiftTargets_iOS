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

    private var shootsPerSession: Int = 5
    private(set) var roundsPerSession: Int = 0
    private var timerLimit: Int = 0
    
    private(set) var currentRound: Int = 0
    private var currentPlayerIndex: Int = 0
    var currentPlayer: Player {
        return players[currentPlayerIndex]
    }
    
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
    
    func reset() {
        currentPlayerIndex = 0
        currentRound = 0
    }
    
    func nextPlayerAndRound() {
        if currentPlayerIndex < players.count - 1 {
            currentPlayerIndex += 1
        } else {
            currentPlayerIndex = 0
            currentRound += 1
        }
        
        if currentRound >= roundsPerSession {
            state = waitState
        } else {
            state = shootState
        }
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
        gameVC.targetsView.setTargets(targetStates: notification.targetStates)
        state.targetNotifReceive(targetNotification: notification)
    }
    
    func receiveError(msg: String) {
        print(msg)
    }
}
