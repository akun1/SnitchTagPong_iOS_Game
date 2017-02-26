//
//  GameScene.swift
//  Pong
//
//  Created by Akash Kundu on 2/23/17.
//  Copyright © 2017 Akash Kundu. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    
    var player:SKSpriteNode?
    var ball:SKSpriteNode?
    var fingerOnPaddle: Bool = false
    var livesLabel:SKLabelNode?
    var livesLabel2:SKLabelNode?
    var livesLabel3:SKLabelNode?
    var scoreLabel:SKLabelNode?
    var finalScore:SKLabelNode?
    var score:Int = 0
    var gameOver:SKSpriteNode?
    var finalScoreLabel:SKLabelNode?
    var gameOverLabel:SKLabelNode?
    var restartLabel:SKLabelNode?
    var endLevelLabel:SKLabelNode?
    var levelLabel:SKLabelNode?

    
    let noCategory:UInt32 = 0
    let playerCategory: UInt32 = 0b1
    let ballCategory: UInt32 = 0b1 << 1
    let bottomCategory: UInt32 = 0b1 << 2

    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx:0,dy:0)
        
        let bottomRect = CGRect(x: frame.origin.x,y: frame.origin.y,width: frame.size.width,height: 10)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        bottom.physicsBody?.restitution = 1
        bottom.physicsBody?.friction = 0
        bottom.physicsBody?.linearDamping = 0
        addChild(bottom)
        
        
        let flames:SKEmitterNode = SKEmitterNode(fileNamed: "flames")!
        flames.position.x = frame.origin.x
        flames.position.y = frame.origin.y
        flames.particlePositionRange = CGVector(dx:frame.size.width * 2,dy:2)
        addChild(flames)

        
        livesLabel = self.childNode(withName: "livesLabel") as? SKLabelNode
        livesLabel?.text = "Keep the Golden Snitch away from the fire!"
        scoreLabel = self.childNode(withName: "scoreLabel") as? SKLabelNode
        scoreLabel?.text = "\(score)"
        livesLabel2 = self.childNode(withName: "livesLabel2") as? SKLabelNode
        livesLabel2?.text = "Every time the snitch is hit, score goes up"
        livesLabel3 = self.childNode(withName: "livesLabel3") as? SKLabelNode
        livesLabel3?.text = "by one. Every 5 points, the snitch gets faster!"
        player = self.childNode(withName: "player") as? SKSpriteNode
        ball = self.childNode(withName: "ball") as? SKSpriteNode
        gameOver = self.childNode(withName: "gameOver") as? SKSpriteNode
        finalScoreLabel = self.childNode(withName: "finalScoreLabel") as? SKLabelNode
        gameOverLabel = self.childNode(withName: "gameOverLabel") as? SKLabelNode
        restartLabel = self.childNode(withName: "restartLabel") as? SKLabelNode
        endLevelLabel = self.childNode(withName: "endLevelLabel") as? SKLabelNode
        levelLabel = self.childNode(withName: "levelLabel") as? SKLabelNode
        
        levelLabel?.text = "Level: 1"
        
        gameOver?.size.height = self.size.height
        gameOver?.size.width = self.size.width
        
        endLevelLabel?.isHidden = true
        restartLabel?.isHidden = true
        gameOver?.isHidden = true
        finalScoreLabel?.isHidden = true
        gameOverLabel?.isHidden = true
        
        let trailNode = SKNode()
        trailNode.zPosition = 1
        addChild(trailNode)
        let trail:SKEmitterNode = SKEmitterNode(fileNamed: "trail")!
        trail.targetNode = trailNode
        ball?.addChild(trail)
        
        
        bottom.physicsBody?.categoryBitMask = bottomCategory
        bottom.physicsBody?.collisionBitMask = ballCategory
        bottom.physicsBody?.contactTestBitMask = ballCategory
        
        player?.physicsBody?.categoryBitMask = playerCategory
        player?.physicsBody?.collisionBitMask = ballCategory
        player?.physicsBody?.contactTestBitMask = ballCategory
        
        ball?.physicsBody?.categoryBitMask = ballCategory
        ball?.physicsBody?.collisionBitMask = playerCategory
        ball?.physicsBody?.contactTestBitMask = playerCategory
        
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
        ball?.physicsBody?.applyImpulse(CGVector(dx: 10,dy: -30 ))
        
        
        }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let cA: UInt32 = contact.bodyA.categoryBitMask
        let cB: UInt32 = contact.bodyB.categoryBitMask
        
    if(contact.bodyA.node?.parent != nil && contact.bodyB.node?.parent != nil)
        {
        
            if cA == bottomCategory || cB == bottomCategory
            {
                if cA == bottomCategory
                {
                    let explosion: SKEmitterNode = SKEmitterNode(fileNamed: "explosion")!
                    explosion.position = contact.bodyB.node!.position
                    self.addChild(explosion)
                    contact.bodyB.node?.removeFromParent()
                    finalScore?.text = "Final Score: \(score)"
                    gameOver(FinalScore: score)
                    
                }
                else
                {
                    let explosion: SKEmitterNode = SKEmitterNode(fileNamed: "explosion")!
                    explosion.position = contact.bodyA.node!.position
                    self.addChild(explosion)
                    contact.bodyA.node?.removeFromParent()
                    finalScore?.text = "Final Score: \(score)"
                    gameOver(FinalScore: score)
                    
                }
            }
            else if cA == playerCategory || cB == playerCategory
            {
                score += 1
                scoreLabel?.text = "\(score)"
                levelLabel?.text = "Level: \((score/5)+1)"
                if score % 5 == 0
                {
                    ball?.physicsBody?.mass = (ball?.physicsBody?.mass)!/1.3
                    ball?.physicsBody?.applyImpulse(CGVector(dx: 7, dy: 7), at: CGPoint(x: (ball?.position.x)!, y: (ball?.position.y)!))
                }
            }

        }
    }
    
    func gameOver(FinalScore: Int)
    {
        finalScoreLabel?.text = "Final Score: \(FinalScore)"
        endLevelLabel?.text = "Level Reached: \(Int(FinalScore/5)+1)"
        endLevelLabel?.isHidden = false
        restartLabel?.isHidden = false
        gameOver?.isHidden = false
        finalScoreLabel?.isHidden = false
        gameOverLabel?.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute:
            {
                if let view = self.view
                {
                // Load the SKScene from 'GameScene.sks'
                    if let scene = SKScene(fileNamed: "GameScene")
                    {
                        // Set the scale mode to scale to fit the window
                        scene.scaleMode = .aspectFill
                    
                    // Present the scene
                    view.presentScene(scene)

                    }
                }
            })
        }

    func touchDown(atPoint pos : CGPoint) {
        
       player?.position = pos
       
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
        player?.position = pos
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
            }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
                for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
