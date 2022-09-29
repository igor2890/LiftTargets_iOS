//
//  ConfigureGameController.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 03.08.2022.
//

import UIKit

class ConfigureGameController: UITableViewController {
    
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    var settings = [
        Setting(
            type: .rounds,
            name: "Rounds per game:",
            values: [1,2,3,4,5],
            selectedIndex: 2,
            enabled: true),
        Setting(
            type: .shoots,
            name: "Shoots per round:",
            values: [5,6,7,8],
            selectedIndex: 0,
            enabled: true),
        Setting(
            type: .timeLimit,
            name: "Time limit in sec:",
            values: [30,45,60],
            selectedIndex: 1,
            enabled: true),
    ]
    
    var playersLimit = 4
    
    private var players: [Player] = [] {
        didSet {
            playButton.isEnabled = players.count == 0 ? false : true
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Configure game"
        
        playButton.isEnabled = false
        tableView.sectionHeaderTopPadding = 0.0
        
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let target = DeviceManager.instance.target {
            if target.state == .disconnected {
                target.connect()
            }
        } else {
            showSearchVC(for: .target)
        }
        
        DeviceManager.instance.guns.forEach { if $0.state == .disconnected { $0.connect()} }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    @IBAction func playTapped(_ sender: Any) {
        if DeviceManager.instance.target != nil {
            let gameVC = GameController(nibName: "GameController", bundle: nil)
            gameVC.modalPresentationStyle = .fullScreen
            let game = Game(gameVC: gameVC, players: players, settings: settings)
            gameVC.game = game
            present(gameVC, animated: true)
        } else {
            showSearchVC(for: .target)
        }
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        DeviceManager.instance.disconnectAll()
        navigationController?.popViewController(animated: true)
    }
    
    private func showSearchVC(for type: DeviceType, with player: Player? = nil) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let searchVC = story.instantiateViewController(withIdentifier: "searchVC") as! SearchController
        searchVC.modalPresentationStyle = .popover
        searchVC.searchedDeviceType = type
        searchVC.currentPlayer = player
        present(searchVC, animated: true)
    }

    // MARK: TableDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? players.count + 1 : settings.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Players" : "Settings"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            var config = cell.defaultContentConfiguration()
            if players.count == indexPath.row {
                config.text = "+"
            } else {
                config.text = players[indexPath.row].name
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
            cell.enabledSwitch.addTarget(self, action: #selector(enabledChanged(_:)), for: .valueChanged)
            cell.enabledSwitch.tag = indexPath.row
            return cell
        }
    }
    
    @objc func segmentValueChanged(_ sender: UISegmentedControl) {
        settings[sender.tag].selectedIndex = sender.selectedSegmentIndex
    }
    
    @objc func enabledChanged(_ sender: UISwitch) {
        settings[sender.tag].enabled = sender.isOn
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
            if indexPath.row == players.count,
               players.count < playersLimit {
                let alert = UIAlertController(title: "Add player", message: "Enter the player name", preferredStyle: .alert)
                alert.addTextField() { textField in
                    textField.autocorrectionType = .no
                    textField.autocapitalizationType = .words
                    textField.placeholder = "name"
                }
                let addAction = UIAlertAction(title: "Add", style: .default) { [weak alert] _ in
                    guard let alert = alert,
                          let textField = alert.textFields?[0],
                          let name = textField.text,
                          name != ""
                    else { return }
                    let player = Player(name: name)
                    if self.players.contains(where: { $0.name == player.name}) { return }
                    self.players.append(player)
                    
                    tableView.reloadSections(IndexSet(integer: 0), with: .automatic)

                    self.showSearchVC(for: .gun, with: player)
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
        if indexPath.row == players.count || indexPath.section == 1 {
            return UISwipeActionsConfiguration()
        }
        let delAction = UIContextualAction(style: .destructive, title: "Delete"){ _,_,_ in
            let name = self.players[indexPath.row].name
            DeviceManager.instance.disconnect(name: name)
            self.players.remove(at: indexPath.row)
            tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
        }
        return UISwipeActionsConfiguration(actions: [delAction])
    }

}
//MARK: Drag players
extension ConfigureGameController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, dragSessionAllowsMoveOperation session: UIDragSession) -> Bool {
        print(session.description)
        return true
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.section == 1 || proposedDestinationIndexPath.row >= players.count {
            return sourceIndexPath
        }
        
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if indexPath.row >= players.count || indexPath.section != 0 { return [] }
        
        
        
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = players[indexPath.row]
        return [ dragItem ]
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 && indexPath.row < players.count ? true : false
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            if destinationIndexPath.section == 0,
               destinationIndexPath.row < players.count {
                let player = players.remove(at: sourceIndexPath.row)
                players.insert(player, at: destinationIndexPath.row)
            } else {
                tableView.reloadData()
            }
        }
}
