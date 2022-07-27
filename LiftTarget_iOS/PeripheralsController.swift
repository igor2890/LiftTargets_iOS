//
//  PeripheralsController.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 02.07.2022.
//

import UIKit
import CoreBluetooth

class PeripheralsController: UITableViewController {
    
    var bleManager: CBCentralManager!
    var peripherals: Set<CBPeripheral> = [] {
        didSet {
            peripheralsArray = Array(peripherals)
                .sorted { $0.name! > $1.name!
            }
        }
    }
    var peripheralsArray = [CBPeripheral]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    weak var rootVC: StartController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootVC.tableViewVC = self
        tableView.largeContentTitle = "Devices"
        bleManager.scanForPeripherals(withServices: [CBUUID(string: "FFE0")], options: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        bleManager.stopScan()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return peripheralsArray.count
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        if indexPath.section == 1 {
            let peripheral = peripheralsArray[indexPath.row]
            bleManager.connect(peripheral, options: nil)
            dismiss(animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "reuse") else { return UITableViewCell() }
            let peripheral = peripheralsArray[indexPath.row]
            var config = cell.defaultContentConfiguration()
            config.text = peripheral.name
            config.secondaryText = peripheral.identifier.uuidString
            cell.contentConfiguration = config
            return cell
        } else {
            return UITableViewCell()
        }
    }

}
