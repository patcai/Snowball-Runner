//
//  MainScene.swift
//  Snowball Runner
//
//  Created by Patrick Cai on 7/18/16.
//  Copyright © 2016 patcai. All rights reserved.
//

import SpriteKit

class MainScene: SKScene {
    
    var playButton: MSButtonNode!
    
    override func didMoveToView(view: SKView) {
        playButton = self.childNodeWithName("playButton") as! MSButtonNode
        
        playButton.selectedHandler = {
            
            let skView = self.view as SKView!
            
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            scene.scaleMode = .AspectFill
            
            skView.showsPhysics = false
            skView.showsDrawCount = true
            skView.showsFPS = true
            
            skView.presentScene(scene)
        }
        
    }
    
}

