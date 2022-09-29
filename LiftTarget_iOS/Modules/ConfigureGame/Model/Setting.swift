//
//  Setting.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 25.09.2022.
//

import Foundation

enum SettingType {
    case rounds
    case shoots
    case timeLimit
}

struct Setting {
    let type: SettingType
    let name: String
    let values: [Int]
    var selectedIndex: Int
    var enabled: Bool
    
    var value: Int {
        get {
            values[selectedIndex]
        }
    }
}
