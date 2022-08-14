//
//  StartController.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 02.07.2022.
//

import UIKit
import CoreBluetooth

class StartController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate {
    //MARK: Properties

    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    var watchers: [BluetoothWatcher?] = []
    var centralBluetoothManager: CBCentralManager!
    var peripherals: Set<CBPeripheral> = [] {
        didSet {
            peripheralsArray = Array(peripherals)
                .sorted { $0.name! > $1.name!
            }
        }
    }
    var peripheralsArray = [CBPeripheral]() {
        didSet {
            searchVC?.peripheralsInfoList = peripheralsArray.map{
                ($0.name ?? "" ,$0.identifier.uuidString)
            }
        }
    }
    
    var peripheralBluetoothManager: CBPeripheralManager!
    var myPeripheral: CBPeripheral? {
        willSet {
            if newValue != nil {
                disconnectButton.isEnabled = true
                scanButton.isEnabled = false
                playButton.isEnabled = true
            } else {
                disconnectButton.isEnabled = false
                scanButton.isEnabled = true
                playButton.isEnabled = false
            }
        }
    }
    var myCharactericric: CBCharacteristic?
//    var myDescriptor: CBDescriptor?
    var searchVC: SearchController?
    var gameVC: GameController?

    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        centralBluetoothManager = CBCentralManager(delegate:self, queue:nil, options: nil)
        peripheralBluetoothManager = CBPeripheralManager(delegate: self, queue: nil)
        scanButton.isEnabled = false
        disconnectButton.isEnabled = false
        //TODO: TEST!!! CHANGE TO FALSE WHEN REAL USE
        playButton.isEnabled = true
        statusView.clipsToBounds = true
        statusView.layer.cornerRadius = statusView.frame.height / 2
        statusView.backgroundColor = .systemRed
        statusLabel.text = "disconnected"
    }
    
    @IBAction func playTapped(_ sender: Any) {
        performSegue(withIdentifier: "showGameConfig", sender: nil)
    }
    
    private func errorHandler(error: Error?) {
        disconnect()
        clearCBObjects()
    }
    
    //MARK: IBActions
    
    @IBAction func scanButton(_ sender: Any) {
        performSegue(withIdentifier: "showScan", sender: nil)
    }
    
    @IBAction func disconnectButton(_ sender: Any) {
        disconnect()
    }
    
    private func disconnect() {
        if let peripheral = myPeripheral { centralBluetoothManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    //MARK: PrepareForSegue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let searchVC = segue.destination as? SearchController
        {
            searchVC.startVC = self as StartControllerProtocol
            self.searchVC = searchVC
        } else if let configVC = segue.destination as? ConfigureGameController {
            configVC.startVC = self as BluetoothManager
        }
    }
    
    //MARK: CentralManager
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn && myPeripheral == nil {
            scanButton.isEnabled = true
        } else {
            scanButton.isEnabled = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripherals.insert(peripheral)
    }
    
    //TODO: NEED UI THAT SHOWING CONNECTING STATE
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        myPeripheral = peripheral
        myPeripheral?.delegate = self
        myPeripheral?.discoverServices(nil)
        UIView.animate(withDuration: 0.5) {
            self.statusView.backgroundColor = .systemGreen
            self.statusLabel.text = "connected"
        }
        showToast(message: "Connected")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard error == nil else {
            errorHandler(error: error)
            return
        }
        UIView.animate(withDuration: 0.5) {
            self.statusView.backgroundColor = .systemRed
            self.statusLabel.text = "disconnected"
        }
        clearCBObjects()
        showToast(message: "Disconnected")
    }
    
    func clearCBObjects() {
        myPeripheral = nil
        myCharactericric = nil
//        myDescriptor = nil
    }
    
    //MARK: PeripheralManager
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        var message = ""
        switch peripheral.state {
        case .poweredOn:
            message += "poweredOn"
        case .poweredOff:
            message += "poweredOff"
            clearCBObjects()
        case .resetting:
            message += "resetting"
        case .unauthorized:
            message += "unauthorized"
        case .unsupported:
            message += "unsupported"
        default:
            message += "unknown"
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            errorHandler(error: error)
            return
        }
        guard let services = peripheral.services else {
            print("no services finded")
            return
        }
        for service in services {
            if service.uuid == CBUUID(string: "FFE0") {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            errorHandler(error: error)
            return
        }
        guard let characteristics = service.characteristics else {
            print("no characteristics finded")
            return
        }
        for characteristic in characteristics {
            if characteristic.uuid == CBUUID(string: "FFE1") {
                myCharactericric = characteristic
//                peripheral.discoverDescriptors(for: characteristic)
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
//        guard error == nil else {
//            errorHandler(error: error)
//            return
//        }
//        guard let descriptors = characteristic.descriptors
//        else {
//            print("no descriptors finded")
//            return
//        }
//        for descriptor in descriptors {
//            myDescriptor = descriptor
//        }
//    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            errorHandler(error: error)
            return
        }
        print(characteristic.description + "\(characteristic.isNotifying)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            errorHandler(error: error)
            return
        }
        guard let value = characteristic.value else { return }
        let array = [UInt8](value)
//        print(array.description)
//        let newArray = array.dropLast()
//        guard let text = String(bytes: newArray, encoding: .ascii)
//        else {
//            print("decoding error")
//            return
//        }
        notificationWatchers(bytes: array)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            errorHandler(error: error)
            return
        }
    }
    
}
