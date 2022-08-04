//
//  GameController.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 04.08.2022.
//

import UIKit

class GameController: UIViewController {

    var players: [String] = []
    weak var startVC: BluetoothManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        startVC.subscibe(watcher: self)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .landscape }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

extension GameController: BluetoothWatcher {
    func receiveFromPeripheral(bytes: [UInt8]) {
        print("incoming bytes received")
    }
    
}
