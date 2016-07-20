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

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var hillPoints: [CGPoint] = []
    var segmentArray: [SKShapeNode] = []
    var snowball: SKSpriteNode!
    let cam = SKCameraNode()
    var point0: CGPoint = CGPoint(x: 0, y: 0)
    var point1: CGPoint = CGPoint(x: 0, y: 0)
    let segmentSize: CGFloat = 5
    var pathNum = 5
    var onGround = false
    var endX = CGFloat(0)
    var endY = CGFloat(0)
    
    var state: GameState = .Loading

    override func didMoveToView(view: SKView) {
        snowball = childNodeWithName("snowball") as! SKSpriteNode
        
        self.camera = cam
        
        var firstSegment = SKShapeNode()
        firstSegment.strokeColor = UIColor.blueColor()
        firstSegment.fillColor = UIColor.whiteColor()
        firstSegment.lineWidth = 4
        firstSegment.name = "terrain"
        addChild(firstSegment)
        segmentArray.append(firstSegment)
        generateTerrain(firstSegment, startPoint: CGPoint(x: 0, y: 600))
        
        physicsWorld.contactDelegate = self
    }
    
    func generateTerrain(terrain: SKShapeNode, startPoint: CGPoint) {
        
        let minX: CGFloat = 400
        let minY: CGFloat = 140
        
        hillPoints.append(startPoint)
        
        for i in 0...pathNum {
            let randomX = CGFloat(arc4random_uniform(1400)) + minX
            let randomY = CGFloat(arc4random_uniform(201)) + minY

            var currentX = hillPoints[i].x
            var currentY = hillPoints[i].y
            
            let newX = currentX + randomX
            let newY = currentY - randomY
            
            hillPoints.append(CGPoint(x: newX, y: newY))
        }
        
        let path = UIBezierPath()
        path.moveToPoint(hillPoints[0])
        
        var newPoint1 = CGPoint(x: 0, y: 0)
        
        for i in 1..<pathNum {
            
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
        
        endX = path.currentPoint.x
        endY = path.currentPoint.y
        
        path.addLineToPoint(CGPoint(x: path.currentPoint.x, y: path.currentPoint.y - 600))
        path.addLineToPoint(CGPoint(x: 0, y: 0))
        path.closePath()
        terrain.path = path.CGPath
        
        terrain.physicsBody = SKPhysicsBody(edgeChainFromPath: terrain.path!)
        terrain.physicsBody?.affectedByGravity = false
        terrain.physicsBody?.categoryBitMask = 1
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print(onGround)
        if onGround {
            onGround = false
            snowball.physicsBody?.applyImpulse(CGVectorMake(50, 100))
            snowball.physicsBody?.contactTestBitMask = 1
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        cam.position.y = snowball.position.y
        cam.position.x = snowball.position.x + 300
        
        var currentSnowballPosition = CGPoint(x: snowball.position.x, y: snowball.position.y)
        var currentEndPoint = CGPoint(x: endX, y: endY)
        
        if currentSnowballPosition.x > currentEndPoint.x - 400 {
            var newSegment = SKShapeNode()
            newSegment.strokeColor = UIColor.purpleColor()
            newSegment.fillColor = UIColor.whiteColor()
            newSegment.lineWidth = 4
            newSegment.name = "terrain"
            hillPoints.removeAll()
            addChild(newSegment)
            segmentArray.append(newSegment)
            segmentArray.removeFirst()
            generateTerrain(newSegment, startPoint: currentEndPoint)
        }
        if currentEndPoint.x < cam.position.x {
            
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let contactA: SKPhysicsBody = contact.bodyA
        let contactB: SKPhysicsBody = contact.bodyB
        
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        if nodeA.name == "snowball" && nodeB.name == "terrain" {
            onGround = true
            snowball.physicsBody?.contactTestBitMask = 0
        }
        
        if nodeA.name == "terrain" && nodeB.name == "snowball" {
            onGround = true
            snowball.physicsBody?.contactTestBitMask = 0
        }
    }
}
    




