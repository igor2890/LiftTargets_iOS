//
//  BluetoothManager.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 04.08.2022.
//

import Foundation
import CoreBluetooth

protocol BluetoothSubscriber {
    func catchMessage() -> [UInt8]
}

protocol BluetoothManagerProtocol {
    func subscribe(_ subscriber: BluetoothSubscriber)
}

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate {
    
    private var subscribers: [BluetoothSubscriber] = []
    
    
}

extension BluetoothManager: BluetoothManagerProtocol {
    func subscribe(_ subscriber: BluetoothSubscriber) {
        subscribers.append(subscriber)
    }
}
