//
//  PeripheralsController.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 02.07.2022.
//

import UIKit

class SearchController: UITableViewController {
    
    var peripheralsInfoList: [(String,String)] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var mainVC: MainControllerProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select target"
        
        mainVC.startScan()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        mainVC.stopScan()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralsInfoList.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        mainVC.connect(peripheralAt: indexPath.row)
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reuse") else { return UITableViewCell() }
        let peripheralInfo = peripheralsInfoList[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = peripheralInfo.0
        config.secondaryText = peripheralInfo.1
        cell.contentConfiguration = config
        return cell
    }
    
}
