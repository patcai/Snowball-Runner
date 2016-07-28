//
//  GameOverScene.swift
//  Snowball Runner
//
//  Created by Patrick Cai on 7/28/16.
//  Copyright © 2016 patcai. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    var restartButton: MSButtonNode!
    
    override func didMoveToView(view: SKView) {
        restartButton = self.childNodeWithName("restartButton") as! MSButtonNode
    
        restartButton.selectedHandler = {
            let skView = self.view as SKView!
            
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            scene.scaleMode = .AspectFill
            
            skView.showsPhysics = true
            skView.showsDrawCount = true
            skView.showsFPS = true
            
        
            skView.presentScene(scene)
        }
    }
    
}


