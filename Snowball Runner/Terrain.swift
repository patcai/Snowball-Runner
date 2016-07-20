//
//  Terrain.swift
//  Snowball Runner
//
//  Created by Patrick Cai on 7/20/16.
//  Copyright © 2016 patcai. All rights reserved.
//

import Foundation
import SpriteKit

class Terrain: SKShapeNode {
    
    var startPoint: CGPoint = CGPoint(x: 0, y: 0)
    var endPoint: CGPoint = CGPoint(x: 0, y: 0)
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}