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
    var inUse = false
    
    override init() {
        super.init()
        fillColor = UIColor.init(red: 204 / 255, green: 208 / 255, blue: 220 / 255, alpha: 1)
        strokeColor = UIColor.clearColor()
        lineWidth = 4
        name = "terrain"
    }
    
    deinit {
        print("remove terrain")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}