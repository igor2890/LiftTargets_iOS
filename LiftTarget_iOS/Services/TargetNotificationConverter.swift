//
//  TargetNotificationConverter.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 06.08.2022.
//

import Foundation

typealias Milliseconds = Int
typealias IsDown = Bool

enum TargetNotifType: String {
    case start = "S"
    case notif = "N"
    case end = "E"
}

struct TargetNotification: CustomStringConvertible {
    let timeStamp: Milliseconds
    let targetStates: [IsDown]
    let type: TargetNotifType
    
    var isAllUp: Bool {
        var result = true
        targetStates.forEach { if $0 {result = false} }
        return result
    }
    
    var isAllDown: Bool {
        var result = true
        targetStates.forEach { if !$0 {result = false} }
        return result
    }
    
    var description: String {
        return "At \(timeStamp) milliseconds targets are \(targetStates)"
    }
}

class TargetNotificationConverter {
    static let shared = TargetNotificationConverter()
    
    private init() {}
    
    func convert(bytes array: [UInt8]) -> TargetNotification {
        let timeStamp =
            (Int(array[0]) << 24) +
            (Int(array[1]) << 16) +
            (Int(array[2]) << 8) +
            Int(array[3])
        let targetStates: [Bool] = [
            array[4] >> 4 & 1 == 1,
            array[4] >> 3 & 1 == 1,
            array[4] >> 2 & 1 == 1,
            array[4] >> 1 & 1 == 1,
            array[4] & 1 == 1,
        ]
        
        
        let char = String(bytes: [array[5]], encoding: .ascii)
        var type: TargetNotifType
        switch char {
        case TargetNotifType.start.rawValue:
            type = .start
        case TargetNotifType.notif.rawValue:
            type = .notif
        case TargetNotifType.end.rawValue:
            type = .end
        default:
            type = .notif
        }
        
        return TargetNotification(
            timeStamp: timeStamp,
            targetStates: targetStates,
            type: type)
    }
}

