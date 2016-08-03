//
//  Coin.swift
//  Snowball Runner
//
//  Created by Patrick Cai on 8/3/16.
//  Copyright © 2016 patcai. All rights reserved.
//

import Foundation
import SpriteKit

class Coin: SKSpriteNode {
    
    init() {
        let texture = SKTexture(imageNamed: "coin")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        zPosition = 4
        
        name = "coin"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}