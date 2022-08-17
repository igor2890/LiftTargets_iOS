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
    case timeLimit
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
            values: [1,2,3,4,5],
            selectedIndex: 2),
        Setting(
            type: .shoots,
            name: "Shoots per round:",
            values: [5,6,7,8],
            selectedIndex: 0),
        Setting(
            type: .timeLimit,
            name: "Time limit in sec:",
            values: [30,45,60],
            selectedIndex: 1),
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
        
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? playersNames.count + 1 : settings.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Players" : "Settings"
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

extension ConfigureGameController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, dragSessionAllowsMoveOperation session: UIDragSession) -> Bool {
        print(session.description)
        return true
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.section == 1 || proposedDestinationIndexPath.row >= playersNames.count {
            return sourceIndexPath
        }
        
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if indexPath.row >= playersNames.count || indexPath.section != 0 { return [] }
        
        
        
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = playersNames[indexPath.row]
        return [ dragItem ]
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 && indexPath.row < playersNames.count ? true : false
    }
    //TODO: исправить аутофрэндж
    override func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath) {
            if destinationIndexPath.section == 0,
               destinationIndexPath.row < playersNames.count {
                let player = playersNames.remove(at: sourceIndexPath.row)
                playersNames.insert(player, at: destinationIndexPath.row)
            } else {
                tableView.reloadData()
            }
        }
}
