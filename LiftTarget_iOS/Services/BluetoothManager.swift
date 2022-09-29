//
//  BluetoothManager.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 24.09.2022.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject {
    var centralBluetoothManager: CBCentralManager!
    var peripheralBluetoothManager: CBPeripheralManager!
    var deviceManager: DeviceManagerForBluetoothManager!
    
    var peripherals: Set<CBPeripheral>{
        get {
            return _peripherals
        }
    }
    private var _peripherals: Set<CBPeripheral> = []
    
    var connectedPeripherals: [CBPeripheral]{
        get {
            return _connectedPeripherals
        }
    }
    private var _connectedPeripherals: [CBPeripheral] = []
    
    private var searchedType: DeviceType?
    
    override init() {
        super.init()
    }
    
    func sendMessageTo(device: Device, msg: String) {
        guard msg != "" else { return }
        let finalText = msg + "\0"
        guard let peripheral = connectedPeripherals.filter({ device.name == $0.name }).first,
              let data = (finalText.data(using: .ascii))
        else { return }
        let chatacteristic = device.characteristic
        peripheral.writeValue(data , for: chatacteristic, type: .withResponse)
    }
    
    func startScan(type: DeviceType) {
        searchedType = type
        centralBluetoothManager.scanForPeripherals(
            withServices: [CBUUID(string: "FFE0")],
            options: nil)
    }
    
    func stopScan() {
        centralBluetoothManager.stopScan()
    }
    
    func connect(name: String) {
        guard let peripheral = peripherals.first(where: { $0.name == name})
        else { return }
        centralBluetoothManager.connect(peripheral, options: nil)
    }
    
    func disconnect(name: String) {
        guard let peripheral = peripherals.first(where: { $0.name == name})
        else { return }
        centralBluetoothManager.cancelPeripheralConnection(peripheral)
    }
    
    func disconnectAll() {
        _connectedPeripherals.forEach {
            centralBluetoothManager.cancelPeripheralConnection($0)
        }
        _connectedPeripherals = []
    }
    
    func clearCBObjects() {
        _connectedPeripherals = []
        _peripherals = []
    }
    
    private func errorHandler(error: Error?) {
        guard let error = error else { return }
        deviceManager.errorHandler(errorMsg: error.localizedDescription)
        clearCBObjects()
    }

}

extension BluetoothManager: CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate {
    //MARK: CentralManager
    func centralManagerDidUpdateState(_ central: CBCentralManager) { }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name,
           let searchedType = searchedType,
           name.lowercased().contains(searchedType.rawValue) {
            _peripherals.insert(peripheral)
            deviceManager.didFind(name: name)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        _connectedPeripherals.append(peripheral)
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        _connectedPeripherals = _connectedPeripherals.filter{$0.name != peripheral.name}
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
                peripheral.setNotifyValue(true, for: characteristic)
                guard let name = peripheral.name else { return }
                let device = Device(name: name, peripheral: peripheral, characteristic: characteristic)
                deviceManager.addDevice(device)
            }
        }
    }
    
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
        guard let name = peripheral.name else { return }
        deviceManager.receivedNotif(bytes: array, from: name)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            errorHandler(error: error)
            return
        }
    }
}
