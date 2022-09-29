//
//  AbstractGameState.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 14.08.2022.
//

import Foundation

protocol AbstractGameState {
    var gameVC: GameController! { get }
    var game: Game! { get }
    
    init(gameVC: GameController, game: Game)
    
    func begin()
    func greenButtonTapped()
    func yellowButtonTapped()
    func redButtonTapped()
    func gunDidShoot(player: Player)
    func targetNotifReceive(targetNotification notif: TargetNotification)
}
