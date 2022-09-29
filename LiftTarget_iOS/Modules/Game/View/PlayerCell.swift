//
//  PlayerCell.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 14.08.2022.
//

import UIKit

class PlayerCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var shootsLabel: UILabel!
    @IBOutlet weak var hitsLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    
    func configure(player: Player) {
        nameLabel.text = player.name
        let shoots = player.totalShoots
        let hits = player.totalHits
        let percent = player.totalPercent
        shootsLabel.text = String(shoots)
        hitsLabel.text = String(hits)
        percentLabel.text = String(percent) + " %"
    }
}
