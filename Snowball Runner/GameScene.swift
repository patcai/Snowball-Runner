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
    var maxSpeed: CGFloat = 600
    let fixedDelta: CFTimeInterval = 1.0 / 60.0
    var spawnTimer: CFTimeInterval = 0
    var cam: SKCameraNode?
    var score: Int = 0
    var highscore: Int = 0
    var scoreLabel: SKLabelNode!
    let scrollSpeed: CGFloat = 0.2
    var scrollLayer: SKNode!
    var coinLayer: SKNode!
    var coinPositions: [CGPoint] = []
    var coinLabel: SKLabelNode!
    var coinCount: Int = 0
    var totalScore: Int = 0
    
    override func didMoveToView(view: SKView) {
        snowball = childNodeWithName("snowball") as! SKSpriteNode
        obstacleLayer = self.childNodeWithName("obstacleLayer")
        cam = childNodeWithName("cam") as? SKCameraNode
        scoreLabel = childNodeWithName("//scoreLabel") as! SKLabelNode
        coinLabel = childNodeWithName("//coinLabel") as! SKLabelNode
        scrollLayer = self.childNodeWithName("scrollLayer")
        coinLayer = self.childNodeWithName("coinLayer")

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
            snowball.physicsBody?.applyImpulse(CGVectorMake(0, 180))
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
        generateCoins()
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
        
        // contact for obstacles and snowball
        if nodeA.name == "snowball" && nodeB.name == "boulder" {
            gameOver()
        }
        
        if nodeA.name == "boulder" && nodeB.name == "snowball" {
            gameOver()
        }
        
        if nodeA.name == "snowball" && nodeB.name == "tree" {
            gameOver()
        }
        
        if nodeA.name == "tree" && nodeB.name == "snowball" {
            gameOver()
        }
        
        if nodeA is Coin && nodeB.name == "snowball" {
            gotCoin(nodeA)
        }
        
        if nodeA.name == "snowball" && nodeB is Coin {
            gotCoin(nodeB)
        }
    }
    
    func generateTerrain(terrain: Terrain, startPoint: CGPoint) {
        
        terrain.startPoint = startPoint
        
        let minX: CGFloat = 450
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
                
                if j == 4 {
                    pointsArray.append(newPoint1)
                }
                
                if j == 50 || j == 60 || j == 70 || j == 80 {
                    coinPositions.append(newPoint1)
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
        let randNum = arc4random_uniform(2)
        
        for obstacle in obstacleLayer.children {
            
            let obstaclePositionX = obstacle.position.x
            
            if obstaclePositionX < currentTerrain.position.x - (frame.width * 2) {
                obstacle.removeFromParent()
            }
            
        }
        if randNum == 1 {
            if pointsArray.count > 0 {
                let boulder = Boulder()
                
                obstacleLayer.addChild(boulder)
                
                let obstaclePosition = pointsArray[0]
                pointsArray.removeAtIndex(0)
                
                boulder.position = obstaclePosition
            }

        } else {
            if pointsArray.count > 0 {
                let tree = Tree()
                obstacleLayer.addChild(tree)
                
                let obstaclePosition = CGPoint(x: pointsArray[0].x, y: pointsArray[0].y + 20)
                pointsArray.removeAtIndex(0)
                
                tree.position = obstaclePosition
            }
        }
    }
    
    func generateCoins() {
        for coin in coinLayer.children {
            
            let coinPositionX = coin.position.x
            
            if coinPositionX < currentTerrain.position.x - (frame.width * 2) {
                coin.removeFromParent()
            }
        }
        
        if coinPositions.count > 0 {
            let coins = Coin()

            coinLayer.addChild(coins)
            
            let coinPosition = CGPoint(x: coinPositions[0].x, y: coinPositions[0].y - 20)
            coinPositions.removeAtIndex(0)
            
            coins.position = coinPosition
        }
    }
    
    func gotCoin(coin: SKNode) {
        coin.removeFromParent()
        coinCount += 1
        coinLabel.text = ("Coins = " + String(coinCount))  
    }

    func gameOver() {
        if score > highscore {
            saveHighScore(score)
            highscore = score
            print("New Highscore = " + String(highscore))
        } else {
            print("Highscore  = " + String(highscore))
        }
        
        let delay: SKAction = SKAction.waitForDuration(1)
        
        let turnRed: SKAction = SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 1.0, duration: 0.1)
        
        let dissolve: SKAction = SKAction.fadeAlphaTo(0.0, duration: 0.2)
        
        let runAgain: SKAction = SKAction.runBlock {
            let skView = self.view as SKView!
            
            let scene = GameOverScene(fileNamed: "GameOverScene")!
            
            scene.scaleMode = .AspectFill
            
            scene.score = self.score
            scene.highscore = self.highscore
            scene.coins = self.coinCount
            
            self.totalScore = self.coinCount + self.score
            
            scene.totalScore = self.totalScore
            
            skView.presentScene(scene)
        }
        snowball.runAction(turnRed)
        snowball.runAction(dissolve)
        runAction(SKAction.sequence([delay, runAgain]))
    }
    
    func saveHighScore(high: Int) {
        NSUserDefaults.standardUserDefaults().setInteger(high, forKey: "highscore")
    }
}