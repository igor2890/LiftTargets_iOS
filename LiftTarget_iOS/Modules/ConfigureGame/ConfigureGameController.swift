//
//  ConfigureGameController.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 03.08.2022.
//

import UIKit

class ConfigureGameController: UITableViewController {

    @IBOutlet weak var playButton: UIBarButtonItem!
    
    private var playersNames: [String] = [] {
        didSet {
            playButton.isEnabled = playersNames.count == 0 ? false : true
            tableView.reloadData()
        }
    }
    private var settings: [String] = ["hi","ho","ha","he"]
    weak var startVC: BluetoothManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playButton.isEnabled = false

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            let count = playersNames.count
            switch count {
            case 4:
                return 4
            default:
                return count+1
            }
        }
        return settings.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Players"
        }
        return "Settings"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        var config = cell.defaultContentConfiguration()
        switch indexPath.section {
        case 0:
            if playersNames.count == indexPath.row {
                config.text = "+"
            } else {
                config.text = playersNames[indexPath.row]
                cell.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
            }
        default:
            config.text = settings[indexPath.row]
        }
        config.textProperties.alignment = .center
        cell.contentConfiguration = config
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        60.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        switch indexPath.section {
        case 0:
            if indexPath.row == playersNames.count {
                let alert = UIAlertController(title: "Add player", message: "Enter the player name", preferredStyle: .alert)
                alert.addTextField() { textField in
                    textField.autocorrectionType = .no
                    textField.autocapitalizationType = .words
                    textField.placeholder = "name"
                }
                let addAction = UIAlertAction(title: "Add", style: .default) { [weak alert] _ in
                    guard let alert = alert,
                          let textField = alert.textFields?[0],
                          let text = textField.text,
                          text != ""
                    else { return }
                    self.playersNames.append(text)
                }
                let canselAction = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(addAction)
                alert.addAction(canselAction)
                present(alert, animated: true)
            }
        default:
            print(settings[indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row == playersNames.count || indexPath.section == 1 {
            return UISwipeActionsConfiguration()
        }
        let delAction = UIContextualAction(style: .destructive, title: "Delete"){ _,_,_ in
            self.playersNames.remove(at: indexPath.row)
        }
        return UISwipeActionsConfiguration(actions: [delAction])
    }

    @IBAction func playTapped(_ sender: Any) {
        let gameVC = GameController(nibName: "GameController", bundle: nil)
        gameVC.modalPresentationStyle = .fullScreen
        let players = playersNames.map { Player(name: $0) }
        gameVC.game = Game(players: players, shootsPerSession: 5, roundsCount: 5)
        gameVC.bluetoothManager = startVC
        present(gameVC, animated: true)
    }

}
