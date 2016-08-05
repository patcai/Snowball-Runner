//
//  Boulder.swift
//  Snowball Runner
//
//  Created by Patrick Cai on 7/25/16.
//  Copyright © 2016 patcai. All rights reserved.
//

import Foundation
import SpriteKit

class Boulder: SKSpriteNode {
    
    init() {
        let texture = SKTexture(imageNamed: "boulder")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        zPosition = -10
        
        name = "boulder"
        
        physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size)
        physicsBody?.dynamic = false
        physicsBody?.allowsRotation = false
        physicsBody?.contactTestBitMask = 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



