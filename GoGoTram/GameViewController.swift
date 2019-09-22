//
//  GameViewController.swift
//  GoGoTram
//
//  Created by Daniel Sykes-Turner on 6/9/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class TramGameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            
            let scene = TramGameScene(size: view.frame.size)
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
//            view.showsFPS = true
//            view.showsNodeCount = true
//            view.showsPhysics = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
