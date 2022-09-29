//
//  PeripheralManager.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 24.09.2022.
//

import Foundation
import CoreBluetooth

protocol DeviceManagerDelegate {
    func didFindDevice(name: String)
    func targetPushNotif(array: [UInt8])
    func gunDidShoot(player: Player)
    func errorHandler(errorMsg: String)
}

protocol DeviceManagerForDelegates {
    var delegate: DeviceManagerDelegate? { get set }
    
    func startSearchTarget()
    func startSearchMuzzels()
    func stopScan()
    func connect(name: String)
    func disconnect(name: String)
    func disconnectAll()
    func setPlayerForGun(player: Player, gun: String)
    func liftTargetsAndAskForStatus()
}

protocol DeviceManagerForBluetoothManager {
    func didFind(name: String)
    @discardableResult func addDevice(_ device: Device) -> Bool
    func receivedNotif(bytes: [UInt8], from name: String)
    func errorHandler(errorMsg: String)
}

class DeviceManager {
    static let instance = DeviceManager()
    
    var target: Device?
    var guns: [Device] = []
    
    var delegate: DeviceManagerDelegate?
    private var bluetoothManager: BluetoothManager
    
    private init() {
        bluetoothManager = BluetoothManager()
        bluetoothManager.centralBluetoothManager = CBCentralManager(delegate:bluetoothManager, queue:nil, options: nil)
        bluetoothManager.peripheralBluetoothManager = CBPeripheralManager(delegate: bluetoothManager, queue: nil)
        bluetoothManager.deviceManager = self
    }
}

extension DeviceManager: DeviceManagerForDelegates {
    func startSearchTarget() {
        bluetoothManager.startScan(type: .target)
    }
    
    func startSearchMuzzels() {
        bluetoothManager.startScan(type: .gun)
    }
    
    func stopScan() {
        bluetoothManager.stopScan()
    }
    
    func connect(name: String) {
        bluetoothManager.connect(name: name)
    }
    
    func disconnect(name: String) {
        if let target = target,
           target.name == name {
            self.target = nil
        } else {
            guns = guns.filter({ $0.name != name })
        }
        bluetoothManager.disconnect(name: name)
    }
    
    func disconnectAll() {
        bluetoothManager.disconnectAll()
        target = nil
        guns = []
    }
    
    func setPlayerForGun(player: Player, gun: String) {
        guard let gun = guns.first(where: { $0.name == gun }) else { return }
        gun.player = player
    }
    
    func liftTargetsAndAskForStatus() {
        guard let target = target else { return }
        bluetoothManager.sendMessageTo(device: target, msg: "+U")
    }
}

extension DeviceManager: DeviceManagerForBluetoothManager {
    func didFind(name: String) {
        delegate?.didFindDevice(name: name)
    }
    
    @discardableResult
    func addDevice(_ device: Device) -> Bool {
        switch device.type {
        case .target:
            target = device
            return true
        case .gun:
            if !guns.contains(where: { $0.name == device.name }) {
                guns.append(device)
            }
            return true
        default:
            return false
        }
    }
    
    func receivedNotif(bytes: [UInt8], from name: String){
        if name == target?.name {
            delegate?.targetPushNotif(array: bytes)
        } else {
            guard let gun = guns.first(where: { $0.name == name }),
                  let player = gun.player
            else { return }
            delegate?.gunDidShoot(player: player)
        }
    }
    
    func errorHandler(errorMsg: String) {
        delegate?.errorHandler(errorMsg: errorMsg)
    }
}
