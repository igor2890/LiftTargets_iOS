//
//  StartController+Ext.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 05.08.2022.
//

import UIKit
import CoreBluetooth

protocol StartControllerProtocol: AnyObject {
    func stopScan()
    func startScan()
    func connect(peripheralAt index: Int)
}

protocol BluetoothWatcher: AnyObject {
    func receiveFromPeripheral(bytes: [UInt8])
}

protocol BluetoothManager: AnyObject {
    func subscibe(watcher: BluetoothWatcher)
    func sendToPeripheral(bytes: [UInt8])
}

extension StartController: StartControllerProtocol {
    func startScan() {
        centralBluetoothManager.scanForPeripherals(
            withServices: [CBUUID(string: "FFE0")],
            options: nil)
    }
    
    func stopScan() {
        centralBluetoothManager.stopScan()
    }
    
    func connect(peripheralAt index: Int) {
        let peripheral = peripheralsArray[index]
        centralBluetoothManager.connect(peripheral, options: nil)
    }
}

extension StartController: BluetoothManager {    
    func subscibe(watcher: BluetoothWatcher) {
        watchers = watchers.filter { $0 != nil }
        weak var newWatcher = watcher
        watchers.append(newWatcher)
    }
    
    func sendToPeripheral(bytes: [UInt8]) {
        watchers.forEach { $0?.receiveFromPeripheral(bytes: bytes) }
    }
}

