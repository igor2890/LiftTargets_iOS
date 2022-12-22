//
//  Devices.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 24.09.2022.
//

import Foundation
import CoreBluetooth

enum DeviceType: String {
    case target = "target"
    case gun = "gun"
    case undefined
}

class Device {
    let name: String
    let type: DeviceType
    let peripheral: CBPeripheral
    let characteristic: CBCharacteristic
    weak var player: Player?
    
    var state: CBPeripheralState {
        get {
            return peripheral.state
        }
    }
    
    init(name: String, peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        self.name = name
        if name.lowercased().contains("target") {
            self.type = .target
        } else if name.lowercased().contains("gun") {
            self.type = .gun
        } else {
            self.type = .undefined
        }
        self.peripheral = peripheral
        self.characteristic = characteristic
    }
    
    func connect() {
        DeviceManager.instance.connect(name: name)
    }
    
    func disconnect() {
        DeviceManager.instance.disconnect(name: self.name)
    }
}
