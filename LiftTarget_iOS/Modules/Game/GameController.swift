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
    
    var isScreenAlwaysOn: Bool = false {
        willSet {
            UIApplication.shared.isIdleTimerDisabled = newValue
        }
    }
    
    let buttonsCornerRadius = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        
        playersTableView.delegate = self
        playersTableView.dataSource = self
        playersTableView.isScrollEnabled = false
        playersTableView.register(
            UINib(nibName: "PlayerCell", bundle: nil),
            forCellReuseIdentifier: "playerCell")
        
        greenButton.clipsToBounds = true
        yellowButton.clipsToBounds = true
        redButton.clipsToBounds = true
        greenButton.layer.cornerRadius = buttonsCornerRadius
        yellowButton.layer.cornerRadius = buttonsCornerRadius
        redButton.layer.cornerRadius = buttonsCornerRadius
        
        game.configure()
        game.bluetoothManager = bluetoothManager
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
        bluetoothManager.subscribe(watcher: game)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        bluetoothManager.unsubscribe(watcher: game)
    }
    
    //TODO: timer
    
    @IBAction func greenButtonTapped(_ sender: Any) {
        game.greenButtonTapped()
    }
    @IBAction func yellowButtonTapped(_ sender: Any) {
        game.yellowButtonTapped()
    }
    @IBAction func redButtonTapped(_ sender: Any) {
        game.redButtonTapped()
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
