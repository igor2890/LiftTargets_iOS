//
//  GameController.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 07.08.2022.
//

import UIKit

class GameController: UIViewController {
    @IBOutlet weak var currentNameLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var targetsView: TargetsView!
    
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    
    @IBOutlet weak var playersTableView: UITableView!
    
    var game: Game!
    weak var bluetoothManager: BluetoothManager!
    
    var timer: Timer?
    var timerCount: Double = 0.0
    var timerInterval = 0.1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        
        playersTableView.delegate = self
        playersTableView.dataSource = self
        playersTableView.isScrollEnabled = false
        playersTableView.register(
            UINib(nibName: "PlayerCell", bundle: nil),
            forCellReuseIdentifier: "playerCell")
        
        game.configure()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .landscape }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeLeft
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        bluetoothManager.subscribe(watcher: game)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        bluetoothManager.unsubscribe(watcher: game)
    }
    
    func setTimer(time: Double) {
        timerCount = time
        timerLabel.text = String(format: "%.1f", timerCount)
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
    func timerFires() {
        setTimer(time: timerCount + timerInterval)
    }
    
    @IBAction func greenButtonTapped(_ sender: Any) {
        game.state.greenButtonTapped()
    }
    @IBAction func yellowButtonTapped(_ sender: Any) {
        game.state.yellowButtonTapped()
    }
    @IBAction func redButtonTapped(_ sender: Any) {
        game.state.redButtonTapped()
    }
}

extension GameController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        game.players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell") as? PlayerCell
        else { return UITableViewCell() }
        let player = game.players[indexPath.row]
        cell.configure(player: player)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.bounds.size.height / 4
    }
    
    
}
