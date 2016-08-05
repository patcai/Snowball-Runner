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
    var scoreLabel: SKLabelNode!
    var coinLabel: SKLabelNode!
    var totalLabel: SKLabelNode!
    var highLabel: SKLabelNode!
    var score = 0
    var coins = 0
    var totalScore = 0
    var highscore = 0
    
    override func didMoveToView(view: SKView) {
        restartButton = self.childNodeWithName("restartButton") as! MSButtonNode
        scoreLabel = childNodeWithName("scoreLabel") as! SKLabelNode
        coinLabel = childNodeWithName("coinLabel") as! SKLabelNode
        totalLabel = childNodeWithName("totalLabel") as! SKLabelNode
        highLabel = childNodeWithName("highLabel") as! SKLabelNode
        
        scoreLabel.text = "Score: \(score)"
        coinLabel.text = "Coins: \(coins)"
        totalLabel.text = "Total Score: \(totalScore)"
        highLabel.text = "Highscore: \(highscore)"
    
        restartButton.selectedHandler = {
            let skView = self.view as SKView!
            
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            scene.scaleMode = .AspectFill
        
            skView.presentScene(scene)
        }
    }
    
}


