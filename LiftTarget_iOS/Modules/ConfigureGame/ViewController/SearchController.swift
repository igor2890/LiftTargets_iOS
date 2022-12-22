//
//  PeripheralsController.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 02.07.2022.
//

import UIKit

class SearchController: UITableViewController {
    
    var devices: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchedDeviceType: DeviceType = .target
    var currentPlayer: Player?
    
    var deviceManager: DeviceManagerForDelegates?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select target"
        
        deviceManager = DeviceManager.instance
        deviceManager?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if searchedDeviceType == .target {
            deviceManager?.startSearchTarget()
        } else if searchedDeviceType == .gun {
            deviceManager?.startSearchMuzzels()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        deviceManager?.stopScan()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        100.0
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 50)
        header.textLabel?.frame = header.bounds
        header.textLabel?.adjustsFontSizeToFitWidth = true
        header.textLabel?.minimumScaleFactor = 0.5
        header.textLabel?.textAlignment = .center
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchedDeviceType == .target {
            return "Select target to connect"
        }
        guard let name = currentPlayer?.name else { return "Some error :("}
        return "Select gun for \(name)"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        let device = devices[indexPath.row]
        deviceManager?.connect(name: device)
        if searchedDeviceType == .gun,
           let currentPlayer = currentPlayer {
            deviceManager?.setPlayerForGun(player: currentPlayer, gun: device)
        }
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell") else { return UITableViewCell() }
        let peripheralInfo = devices[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = peripheralInfo
        cell.contentConfiguration = config
        return cell
    }
    
}

extension SearchController: DeviceManagerDelegate {
    
    func didFindDevice(name: String) {
        devices.append(name)
    }
    
    func targetPushNotif(notif: TargetNotification) {}
    func gunDidShoot(player: Player) {}
    
    func errorHandler(errorMsg: String) {
        showToast(message: errorMsg)
    }
    

}
