//
//  TargetNotificationConverter.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 06.08.2022.
//

import Foundation

typealias Milliseconds = UInt32
typealias IsDown = Bool

struct TargetNotification: CustomStringConvertible {
    let timeStamp: Milliseconds
    let targetStates: [IsDown]
    let voltage: Double
    
    var description: String {
        return "At \(timeStamp) milliseconds targets are \(targetStates) \nBattery voltage is \(voltage)V"
    }
}

class TargetNotificationConverter {
    static let shared = TargetNotificationConverter()
    
    private init() {}
    
    func convert(bytes array: [UInt8]) -> TargetNotification {
        let timeStamp =
            (UInt32(array[0]) << 24) +
            (UInt32(array[1]) << 16) +
            (UInt32(array[2]) << 8) +
            UInt32(array[3])
        let targetStates: [Bool] = [
            array[4] << 4 & 1 == 1,
            array[4] << 3 & 1 == 1,
            array[4] << 2 & 1 == 1,
            array[4] << 1 & 1 == 1,
            array[4] & 1 == 1,
        ]
        let voltage = Double(array[5]) / 10
        
        return TargetNotification(
            timeStamp: timeStamp,
            targetStates: targetStates,
            voltage: voltage)
    }
}

