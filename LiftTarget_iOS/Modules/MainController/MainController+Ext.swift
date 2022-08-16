//
//  StartController+Ext.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 05.08.2022.
//

import UIKit
import CoreBluetooth

protocol MainControllerProtocol: AnyObject {
    func stopScan()
    func startScan()
    func connect(peripheralAt index: Int)
}

protocol BluetoothManager: AnyObject {
    func subscribe(watcher: BluetoothWatcher)
    func unsubscribe(watcher: BluetoothWatcher)
    func sendMessageToPeripheral(msg: String)
    func notificationWatchers(bytes: [UInt8])
}

protocol BluetoothWatcher: AnyObject {
    func receiveFromTarget(notification: TargetNotification)
    func receiveError(msg: String)
}

extension MainController: MainControllerProtocol {
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

extension MainController: BluetoothManager {
    func subscribe(watcher: BluetoothWatcher) {
        watchers = watchers.filter { $0 != nil }
        weak var newWatcher = watcher
        watchers.append(newWatcher)
    }
    
    func unsubscribe(watcher: BluetoothWatcher) {
        watchers = watchers.filter { $0 !== watcher }
    }
    
    func notificationWatchers(bytes: [UInt8]) {
        watchers = watchers.filter { $0 != nil }
        let notification = TargetNotificationConverter.shared.convert(bytes: bytes)
        watchers.forEach { $0?.receiveFromTarget(notification: notification) }
    }
    
    func sendMessageToPeripheral(msg: String) {
        guard msg != "" else { return }
        let finalText = msg + "\0"
        guard let chatacteristic = myCharactericric,
              let data = (finalText.data(using: .ascii))
        else { return }
        myPeripheral?.writeValue(data , for: chatacteristic, type: .withResponse)
    }
}

