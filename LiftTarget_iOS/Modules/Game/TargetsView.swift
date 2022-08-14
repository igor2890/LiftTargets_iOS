//
//  TargetsView.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 13.08.2022.
//

import UIKit

class TargetsView: UIView {

    var targets: [UIView] = []

    let padding = 10.0
    let spacing = 6.0
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let size = frame.size
        let maxHeight = size.height - (padding * 2)
        let maxWidth = (size.width - (padding * 2 + spacing * 4)) / 5
        let targetSize = maxWidth > maxHeight ? maxHeight : maxWidth
        var mutableX = spacing
        for _ in 0...4 {
            let rect = CGRect(x: mutableX, y: padding, width: targetSize, height: targetSize)
            let target = configuteTargetView(rect: rect)
            addSubview(target)
            targets.append(target)
            mutableX += target.frame.width + spacing
        }
    }

    private func configuteTargetView(rect: CGRect) -> UIView {
        let targetView = UIView(frame: rect)
        targetView.clipsToBounds = true
        targetView.layer.cornerRadius = targetView.frame.width / 2
        targetView.backgroundColor = .black
        targetView.layer.borderWidth = 4.0
        targetView.layer.borderColor = UIColor.black.cgColor
        return targetView
    }
    
    func setTargets(targetStates: [IsDown]){
        guard targetStates.count == 5 else { return }
        var color: UIColor
        for (index, target) in targets.enumerated() {
            if targetStates[index] {
                color = .white
            } else {
                color = .black
            }
            UIView.animate(withDuration: 0.5) {
                target.backgroundColor = color
            }
        }
    }
    
}
