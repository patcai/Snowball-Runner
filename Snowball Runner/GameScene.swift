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
    var segmentArray: [Terrain] = []
    var snowball: SKSpriteNode!
    let cam = SKCameraNode()
    var point0: CGPoint = CGPoint(x: 0, y: 0)
    var point1: CGPoint = CGPoint(x: 0, y: 0)
    let segmentSize: CGFloat = 10
    var pathNum = 4
    var onGround = false
    var currentTerrain: Terrain!
    var obstacle: SKSpriteNode!
    var previousTerrain: Terrain?
    
    var state: GameState = .Loading
    
    
    override func didMoveToView(view: SKView) {
        snowball = childNodeWithName("snowball") as! SKSpriteNode
        //obstacle = childNodeWithName("//obstacle") as! SKSpriteNode
        
        self.camera = cam
        
        let firstSegment = Terrain()
        addChild(firstSegment)
        firstSegment.position = CGPoint(x: 0, y: 0)
        segmentArray.append(firstSegment)
        currentTerrain = firstSegment
        generateTerrain(firstSegment, startPoint: CGPoint(x: 0, y: 600))
        firstSegment.inUse = true
        
        let secondSegment = Terrain()
        secondSegment.position = CGPoint(x: 0, y: 0)
        segmentArray.append(secondSegment)
        secondSegment.inUse = false
        
        physicsWorld.contactDelegate = self
    }
    
    func generateTerrain(terrain: Terrain, startPoint: CGPoint) {
        
        terrain.startPoint = startPoint
        
        let minX: CGFloat = 400
        let minY: CGFloat = 140
        
        hillPoints.append(startPoint)
        
        for i in 0...pathNum {
            let randomX = CGFloat(arc4random_uniform(1400)) + minX
            let randomY = CGFloat(arc4random_uniform(201)) + minY

            let currentX = hillPoints[i].x
            let currentY = hillPoints[i].y
            
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
        
        terrain.endPoint = path.currentPoint
        
        path.addLineToPoint(CGPoint(x: path.currentPoint.x, y: path.currentPoint.y - 600))
        path.addLineToPoint(CGPoint(x: terrain.startPoint.x, y: terrain.startPoint.y - 1000))
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
        
        let currentSnowballPosition = snowball.position
        
        if currentSnowballPosition.x > currentTerrain.endPoint.x - 1000 {
            var newSegment: Terrain!
            for terrain in segmentArray {
                if terrain.inUse == false {
                    newSegment = terrain
                    break
                }
            }
            //newSegment.position = currentTerrain.endPoint
            hillPoints.removeAll()
            addChild(newSegment)
            generateTerrain(newSegment, startPoint: currentTerrain.endPoint)
            previousTerrain = currentTerrain
            currentTerrain = newSegment
            newSegment.inUse = true
            
        }
        
        if previousTerrain?.endPoint.x < cam.position.x - frame.width / 2 {
            previousTerrain?.path = nil
            previousTerrain?.removeFromParent()
            for terrain in segmentArray {
                if terrain == previousTerrain {
                    terrain.inUse = false
                }
            }
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
    




