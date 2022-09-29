//
//  MainController.swift
//  LiftTarget_iOS
//
//  Created by Игорь Андрианов on 02.07.2022.
//

import UIKit
import CoreBluetooth

class MainController: UIViewController {

    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "SmartyTir"
    }
    
    @IBAction func playTapped(_ sender: Any) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "configureGameVC")
        navigationController?.pushViewController(vc, animated: true)
    }
    

}
