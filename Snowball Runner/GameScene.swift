//
//  GameScene.swift
//  Snowball Runner
//
//  Created by Patrick Cai on 7/11/16.
//  Copyright (c) 2016 patcai. All rights reserved.
//

import SpriteKit
import Foundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var hillPoints: [CGPoint] = []
    var segmentArray: [Terrain] = []
    var pointsArray: [CGPoint] = []
    var snowball: SKSpriteNode!
    var point0: CGPoint = CGPoint(x: 0, y: 0)
    var point1: CGPoint = CGPoint(x: 0, y: 0)
    let segmentSize: CGFloat = 10
    var pathNum = 4
    var onGround = false
    var currentTerrain: Terrain!
    var previousTerrain: Terrain?
    var obstacleLayer: SKNode!
    var maxSpeed: CGFloat = 800
    let fixedDelta: CFTimeInterval = 1.0 / 60.0
    var spawnTimer: CFTimeInterval = 0
    var cam: SKCameraNode?
    var score: Int = 0
    var highscore: Int = 0
    var scoreLabel: SKLabelNode!
    
    override func didMoveToView(view: SKView) {
        snowball = childNodeWithName("//snowball") as! SKSpriteNode
        obstacleLayer = self.childNodeWithName("obstacleLayer")
        cam = childNodeWithName("cam") as? SKCameraNode
        scoreLabel = childNodeWithName("//scoreLabel") as! SKLabelNode

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
        highscore = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print(onGround)
        if onGround {
            onGround = false
            snowball.physicsBody?.applyImpulse(CGVectorMake(-20, 130))
            snowball.physicsBody?.contactTestBitMask = 1
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        cam!.position.y = snowball.position.y
        cam!.position.x = snowball.position.x + 300
        
        let currentSnowballPosition = snowball.position
        
        if currentSnowballPosition.x > currentTerrain.endPoint.x - 1000 {
            var newSegment: Terrain!
            for terrain in segmentArray {
                if terrain.inUse == false {
                    newSegment = terrain
                    break
                }
            }
            hillPoints.removeAll()
            addChild(newSegment)
            generateTerrain(newSegment, startPoint: currentTerrain.endPoint)
            previousTerrain = currentTerrain
            currentTerrain = newSegment
            newSegment.inUse = true
        }
        
        if previousTerrain?.endPoint.x < cam!.position.x - frame.width / 2 {
            previousTerrain?.path = nil
            previousTerrain?.removeFromParent()
            for terrain in segmentArray {
                if terrain == previousTerrain {
                    terrain.inUse = false
                }
            }
        }
        
        if snowball.physicsBody?.velocity.dx > maxSpeed {
            snowball.physicsBody?.velocity.dx = maxSpeed
        }
        
        updateObstacles()
        // update score
        spawnTimer += fixedDelta
        score = Int(spawnTimer)
        scoreLabel.text = "Score: \(score)"
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
        
        // contact for boulder and snowball
        if nodeA.name == "snowball" && nodeB.name == "boulder" {
            gameOver()
        }
        
        if nodeA.name == "boulder" && nodeB.name == "snowball" {
            gameOver()
        }
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
                
                if j == 3 {
                    pointsArray.append(newPoint1)
                }
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
    
    func updateObstacles() {
        for obstacle in obstacleLayer.children as! [Boulder] {
            let obstaclePositionX = obstacle.position.x
            
            if obstaclePositionX < currentTerrain.position.x - (frame.width * 2) {
                obstacle.removeFromParent()
            }
            
        }
        if pointsArray.count > 0 {
            let boulder = Boulder()
            boulder.physicsBody = SKPhysicsBody(texture: boulder.texture!, size: boulder.size)
            boulder.physicsBody?.dynamic = false
            boulder.physicsBody?.allowsRotation = false
            boulder.physicsBody?.contactTestBitMask = 2
            
            obstacleLayer.addChild(boulder)
            
            let obstaclePosition = pointsArray[0]
            pointsArray.removeAtIndex(0)
            
            boulder.position = obstaclePosition
        }
    }
    
    func gameOver() {
        if score > highscore {
            saveHighScore(score)
            highscore = score
            print("New Highscore = " + String(highscore))
        } else {
            print("Highscore  = " + String(highscore))
        }
        
        let skView = self.view as SKView!
        
        let scene = GameOverScene(fileNamed: "GameOverScene") as GameOverScene!
        
        scene.scaleMode = .AspectFill
        
        skView.showsPhysics = true
        skView.showsDrawCount = true
        skView.showsFPS = true
        
        skView.presentScene(scene)
    }
    
    func saveHighScore(high: Int) {
        NSUserDefaults.standardUserDefaults().setInteger(high, forKey: "highscore")
    }
}