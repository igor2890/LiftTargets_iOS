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
        shootsLabel.text = String(shoots)
        hitsLabel.text = String(hits)
        if hits == 0 {
            percentLabel.text = "100 %"
        } else {
            percentLabel.text = String(Int(Double(shoots) / Double(hits) * 100)) + " %"
        }
    }
    
}
