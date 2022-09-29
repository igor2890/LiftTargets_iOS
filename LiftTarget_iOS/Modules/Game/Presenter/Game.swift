//
//  Game.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 07.08.2022.
//

import Foundation

class Game {
    weak var gameVC: GameController!
    var deviceManager: DeviceManagerForDelegates!
    
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
    
    var isEnd = false

    private(set) var shootsPerSession: Int = 5
    private(set) var isShootsLimitOn: Bool = false
    
    private(set) var roundsPerSession: Int = 0
    private(set) var isRoundsLimitOn: Bool = false
    
    private(set) var timePerSession: Int = 0
    private(set) var isTimeLimitOn: Bool = false
    
    private(set) var currentRound: Int = 0
    private var currentPlayerIndex: Int = 0
    var currentPlayer: Player {
        return players[currentPlayerIndex]
    }
    
    //MARK: Init
    init(gameVC: GameController, players: [Player], settings: [Setting]) {
        self.players = players
        if let roundCountSetting = settings.first(where: { $0.type == .rounds }) {
            self.roundsPerSession = roundCountSetting.value
            self.isRoundsLimitOn = roundCountSetting.enabled
        }

        if let shootsCountSession = settings.first(where: { $0.type == .shoots }) {
            self.shootsPerSession = shootsCountSession.value
            self.isShootsLimitOn = shootsCountSession.enabled
        }
        
        if let timeLimit = settings.first(where: { $0.type == .timeLimit }) {
            self.timePerSession = timeLimit.value
            self.isTimeLimitOn = timeLimit.enabled
        }
        
        self.gameVC = gameVC
    }
    
    //MARK: Configure
    func configure() {
        waitState = WaitState(gameVC: gameVC, game: self)
        shootState = ShootState(gameVC: gameVC, game: self)
        pauseState = PauseState(gameVC: gameVC, game: self)
        state = waitState
        
        deviceManager = DeviceManager.instance
        deviceManager.delegate = self
    }
    
    //MARK: Actions
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
        
        if isRoundsLimitOn && currentRound >= roundsPerSession {
            isEnd = true
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
        timerCount = timerCount + timerInterval
        setTimer(time: timerCount)
        if isTimeLimitOn && timerCount >= Double(timePerSession) {
            nextPlayerAndRound()
        }
    }
}

//MARK: DeviceManagerDelegate
extension Game: DeviceManagerDelegate {
    func didFindDevice(name: String) {}
    
    func targetPushNotif(array: [UInt8]) {
        let notification = TargetNotificationConverter.shared.convert(bytes: array)
        gameVC.targetsView.setTargets(targetStates: notification.targetStates)
        state.targetNotifReceive(targetNotification: notification)
    }
    
    func gunDidShoot(player: Player) {
        state.gunDidShoot(player: player)
    }
    
    func errorHandler(errorMsg: String) {
        gameVC.showToast(message: errorMsg)
    }
}
