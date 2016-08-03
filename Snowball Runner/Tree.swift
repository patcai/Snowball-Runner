//
//  Tree.swift
//  Snowball Runner
//
//  Created by Patrick Cai on 8/3/16.
//  Copyright © 2016 patcai. All rights reserved.
//

import Foundation
import SpriteKit

class Tree: SKSpriteNode {
    
    init() {
        let texture = SKTexture(imageNamed: "tree")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        zPosition = 4
        physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size)
        physicsBody?.dynamic = false
        physicsBody?.allowsRotation = false
        physicsBody?.contactTestBitMask = 2

        
        name = "tree"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}