//
//  UIVC+Ext.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 14.08.2022.
//

import UIKit

extension UIViewController {
    
    func showToast(message: String, font: UIFont = .systemFont(ofSize: 12.0)) {
        let toastLabel = UILabel(
            frame: CGRect(
                x: self.view.frame.size.width/2 - 125,
                y: self.view.frame.size.height - 100,
                width: 250,
                height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        toastLabel.alpha = 0.0
        self.view.addSubview(toastLabel)
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                toastLabel.alpha = 1.0
            })
        UIView.animate(
            withDuration: 1.0,
            delay: 2.5,
            options: .curveEaseOut,
            animations: {
                toastLabel.alpha = 0.0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
    }
    
    /**
     Must execute in main queue
     */
    func showOk(
        title: String,
        message: String,
        cancelButtonNeeded: Bool = false,
        actionAfterTapOK: @escaping (() -> Void) = {}) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .destructive) {_ in
                actionAfterTapOK()
            }
            alert.addAction(action)
            if cancelButtonNeeded {
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(cancelAction)
            }
            self.present(alert, animated: true)
        }
}
