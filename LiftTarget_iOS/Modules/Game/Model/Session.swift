//
//  Session.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 22.08.2022.
//

import Foundation

class Session {
    var shoots: Int = 0
    var hits: Int = 0
    var startTimeStamp: Int = 0
    var endTimeStamp: Int = 0
    var pauseTime: Int = 0
    var time: Double {
        return Double(endTimeStamp - startTimeStamp - pauseTime) / 1000
    }
    
    init(startTime: Int) {
        self.startTimeStamp = startTime
    }
}
