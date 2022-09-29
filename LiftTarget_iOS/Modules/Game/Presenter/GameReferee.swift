//
//  GameReferee.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 22.08.2022.
//

import Foundation

class GameReferee {
    private init () {}

    static func judge(players: [Player]) -> String {
        var result = ""
        let sortedPlayers = players
            .sorted { $0.totalPercent > $1.totalPercent }
        sortedPlayers.enumerated().forEach { index, player in
            result += "\(index+1). \(player.name) with \(player.totalPercent) and \(player.totalTime)\n"
        }
        return result
    }
}
