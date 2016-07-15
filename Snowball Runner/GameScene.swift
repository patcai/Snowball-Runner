//
//  GameScene.swift
//  Snowball Runner
//
//  Created by Patrick Cai on 7/11/16.
//  Copyright (c) 2016 patcai. All rights reserved.
//

import SpriteKit
import Foundation

enum GameState {
    case Loading, Title, Alive, GameOver
}

class GameScene: SKScene {
    
    var hillPoints: [CGPoint] = []
    
    var cameraTarget: SKNode?
    var testBall: SKSpriteNode!
    var terrain: SKShapeNode!
    let hillCount = 10
    
    var point0: CGPoint = CGPoint(x: 0, y: 0)
    var point1: CGPoint = CGPoint(x: 0, y: 0)
    let segmentSize: CGFloat = 5
    
    var randomXnum = 600
    var randomYnum = 300
    
    override func didMoveToView(view: SKView) {
        testBall = childNodeWithName("testBall") as! SKSpriteNode
        
        terrain = SKShapeNode()
        terrain.strokeColor = UIColor.blueColor()
        addChild(terrain)
        curvyTerrain()
    }
    
    func curvyTerrain() {
        let path = UIBezierPath()
        path.moveToPoint(hillPoints[0])
        
        var newPoint1 = CGPoint(x: 0, y: 0)
        
        
        for i in 1..<hillPoints.count {
            
            point0 = hillPoints[i - 1]
            point1 = hillPoints[i]
            
            let segments = (point1.x - point0.x) / segmentSize
            let dx = (point1.x - point0.x) / segments
            let da = CGFloat(M_PI) / segments
            
            let yMid = (point1.y + point0.y) / 2
            let amplitude = (point0.y - point1.y) / 2
            
            for j in 0...Int(segments) + 1 {
                newPoint1.x = point0.x + (CGFloat(j) * dx)
                newPoint1.y = yMid + (amplitude * cos(da * CGFloat(j)))
                path.addLineToPoint(newPoint1)
            }
        }
        terrain.path = path.CGPath
        terrain.physicsBody = SKPhysicsBody(edgeChainFromPath: terrain.path!)
        terrain.physicsBody?.affectedByGravity = false
    }
    
    func generatePoints() {
        let minX = 400
        let minY = 300
        
        for i in 0...10 {
            let currentX = 
            
            hillPoints.append(CGPoint(x: randomXnum, y: randomYnum))
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        //camera?.position.x = testBall.position.x
        //camera?.position.y = testBall.position.y
        //terrain.position.x -= 8
        //terrain.position.y += 0.8
        
    }
}