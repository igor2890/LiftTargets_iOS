//
//  ConfigureGameController.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 03.08.2022.
//

import UIKit

enum SettingType {
    case rounds
    case shoots
}

struct Setting {
    let type: SettingType
    let name: String
    let values: [Int]
    var selectedIndex: Int
}

class ConfigureGameController: UITableViewController {
    
    @IBOutlet weak var playButton: UIBarButtonItem!
    
    var settings = [
        Setting(
            type: .rounds,
            name: "Rounds per game:",
            values: [1,2,3,4,5,],
            selectedIndex: 2),
        Setting(
            type: .shoots,
            name: "Shoots per round:",
            values: [5,6,7,8,],
            selectedIndex: 0),
    ]
    
    var playersLimit = 4
    
    private var playersNames: [String] = [] {
        didSet {
            playButton.isEnabled = playersNames.count == 0 ? false : true
        }
    }
    weak var mainVC: BluetoothManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playButton.isEnabled = false
        tableView.sectionHeaderTopPadding = 0.0
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return playersNames.count + 1
        }
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Players"
        }
        return "Settings"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            var config = cell.defaultContentConfiguration()
            if playersNames.count == indexPath.row {
                config.text = "+"
            } else {
                config.text = playersNames[indexPath.row]
                cell.backgroundColor = UIColor(white: 0.8, alpha: 1)
            }
            config.textProperties.alignment = .center
            cell.contentConfiguration = config
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as? SettingCell
            else { return UITableViewCell() }
            let setting = settings[indexPath.row]
            cell.configure(setting: setting)
            cell.countSegmentedControl.addTarget(self, action: #selector(segmentValueChanged(_:)), for: .valueChanged)
            cell.countSegmentedControl.tag = indexPath.row
            return cell
        }
    }
    
    @objc func segmentValueChanged(_ sender: UISegmentedControl) {
        settings[sender.tag].selectedIndex = sender.selectedSegmentIndex
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
            if indexPath.row == playersNames.count,
               playersNames.count < playersLimit {
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
                    tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                    //TODO: this
                }
                let canselAction = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(addAction)
                alert.addAction(canselAction)
                present(alert, animated: true)
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row == playersNames.count || indexPath.section == 1 {
            return UISwipeActionsConfiguration()
        }
        let delAction = UIContextualAction(style: .destructive, title: "Delete"){ _,_,_ in
            self.playersNames.remove(at: indexPath.row)
            tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
        }
        return UISwipeActionsConfiguration(actions: [delAction])
    }

    @IBAction func playTapped(_ sender: Any) {
        let gameVC = GameController(nibName: "GameController", bundle: nil)
        gameVC.modalPresentationStyle = .fullScreen
        let players = playersNames.map { Player(name: $0) }
        gameVC.game = Game(gameVC: gameVC, players: players, settings: settings)
        gameVC.bluetoothManager = mainVC
        present(gameVC, animated: true)
    }

}
