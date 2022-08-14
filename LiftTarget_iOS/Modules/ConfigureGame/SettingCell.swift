//
//  SettingCell.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 14.08.2022.
//

import UIKit

class SettingCell: UITableViewCell {

    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var countSegmentedControl: UISegmentedControl!
    
    func configure(setting: Setting) {
        settingLabel.text = setting.name

        countSegmentedControl.removeAllSegments()
        setting.values.enumerated().forEach { (index, element) in
            countSegmentedControl.insertSegment(withTitle: String(element), at: index, animated: false)
        }
        
        countSegmentedControl.selectedSegmentIndex = setting.selectedIndex
    }

}
