//
//  GameScene.swift
//  Breakout
//
//  Created by Nicolas Yepes on 7/11/19.
//  Copyright © 2019 Nicolas Yepes. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ball = SKShapeNode()
    var paddle = SKSpriteNode()
    var bricks = [SKSpriteNode]()
    var loseZone = SKSpriteNode()
    var livesRemaining = SKLabelNode()
    var resultMessage = SKLabelNode()
    var lives = 3
    var numOfBricksRemaining = 21
    var started = false
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        showResult(result: "Tap to start")
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.applyImpulse(CGVector(dx: Int.random(in: -3...3), dy: 5))
    }
    
    func createBackground () {
        let stars = SKTexture(imageNamed: "stars")
        for i in 0...1 {
            let starsBackground = SKSpriteNode(texture: stars)
            starsBackground.zPosition = -1
            starsBackground.position = CGPoint(x: 0, y: starsBackground.size.height * CGFloat(i))
            addChild(starsBackground)
            let moveDown = SKAction.moveBy(x: 0, y: -starsBackground.size.height, duration: 20)
            let moveReset = SKAction.moveBy(x: 0, y: starsBackground.size.height, duration: 0)
            let moveLoop = SKAction.sequence([moveDown, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            starsBackground.run(moveForever)
        }
    }
    
    func makeBall() {
        ball = SKShapeNode(circleOfRadius: 10)
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        ball.strokeColor = UIColor.black
        ball.fillColor = UIColor.blue
        ball.name = "ball"
        
        // physics shape matches ball image
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        // ignores all forces and impulses
        ball.physicsBody?.isDynamic = false
        // use precise collision detection
        ball.physicsBody?.usesPreciseCollisionDetection = true
        // no loss of energy from friction
        ball.physicsBody?.friction = 0
        // gravity is not a factor
        ball.physicsBody?.affectedByGravity = false
        // bounces fully off of other objects
        ball.physicsBody?.restitution = 1
        // does not slow down over time
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.contactTestBitMask = (ball.physicsBody?.collisionBitMask)!
        
        addChild(ball) // add ball object to the view
    }
    
    func makePaddle() {
        paddle = SKSpriteNode(color: UIColor.white, size: CGSize(width: frame.width/4, height: 20))
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + 125)
        paddle.name = "paddle"
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        addChild(paddle)
    }
    
    func makeBrick(x: CGFloat, y: CGFloat, color: UIColor) {
        var brick = SKSpriteNode()
        brick = SKSpriteNode(color: color, size: CGSize(width: (frame.width/7) - 15, height: 20))
        brick.position = CGPoint(x: x, y: y)
        brick.name = "brick"
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.isDynamic = false
        bricks.append(brick)
        addChild(brick)
        
    }
    
    func makeLoseZone() {
        loseZone = SKSpriteNode(color: UIColor.red, size: CGSize(width: frame.width, height: 50))
        loseZone.position = CGPoint(x: frame.midX, y: frame.minY + 25)
        loseZone.name = "loseZone"
        loseZone.physicsBody = SKPhysicsBody(rectangleOf: loseZone.size)
        loseZone.physicsBody?.isDynamic = false
        addChild(loseZone)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (started) {
            var xSpeed = ball.physicsBody!.velocity.dx
            xSpeed = sqrt(xSpeed * xSpeed)
            if xSpeed < 10 {
                ball.physicsBody?.applyImpulse(CGVector(dx: Int.random(in: -3...3), dy: 0))
            }
            var ySpeed = ball.physicsBody!.velocity.dy
            ySpeed = sqrt(ySpeed * ySpeed)
            if ySpeed < 10 {
                ball.physicsBody?.applyImpulse(CGVector(dx: 0, dy: Int.random(in: -3...3)))
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!started) {
            showLives(lives: lives, clear: false)
            resetGame()
            createGame()
            showResult(result: "")
            started = true
        }
        for touch in touches {
            let location = touch.location(in: self)
            paddle.position.x = location.x
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            paddle.position.x = location.x
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        for brick in bricks {
            if contact.bodyA.node == brick || contact.bodyB.node == brick {
                if brick.color == UIColor.red {
                    brick.color = UIColor.orange
                }
                else if brick.color == UIColor.orange {
                    brick.color = UIColor.green
                }
                else {
                    contact.bodyA.node?.removeFromParent()
                    numOfBricksRemaining -= 1
                    if numOfBricksRemaining == 0 {
                        started = false
                        resetGame()
                        showResult(result: "You Won")
                    }
                }
                
            }
        }
        if contact.bodyA.node?.name == "loseZone" ||
            contact.bodyB.node?.name == "loseZone" {
            lives -= 1
            livesRemaining.removeFromParent()
            showLives(lives: lives, clear: false)
            if lives == 0 {
                started = false
                resetGame()
                showResult(result: "You Lost")
            } else {
                ball.removeFromParent()
                makeBall()
                ball.physicsBody?.isDynamic = true
                ball.physicsBody?.applyImpulse(CGVector(dx: Int.random(in: -3...3), dy: 5))
            }
        }
    }
    func createBricks() {
        
        var xValue = -165
        var yValue = 50
        var brickColor = UIColor.red
        
        for i in 1 ... 21 {
            makeBrick(x: frame.midX + CGFloat(xValue), y: frame.maxY - CGFloat(yValue), color: brickColor)
            xValue += 55
            if i == 7 {
                xValue = -165
                yValue = 80
                brickColor = UIColor.orange
            } else if i == 14 {
                xValue = -165
                yValue = 110
                brickColor = UIColor.green
            }
        }
    }
    
    func showLives (lives: Int, clear: Bool) {
        if (!clear) {
            livesRemaining = SKLabelNode(fontNamed: "Chalkduster")
            livesRemaining.text = "Lives: \(lives)"
            livesRemaining.fontSize = 20
            livesRemaining.fontColor = SKColor.black
            livesRemaining.position = CGPoint(x: frame.midX, y: frame.minY+20)
           
        } else {
            livesRemaining.text = ""
        }
        addChild(livesRemaining)
    }
    
    func showResult (result: String) {
        resultMessage = SKLabelNode(fontNamed: "Chalkduster")
        resultMessage.text = result
        resultMessage.fontSize = 40
        resultMessage.fontColor = SKColor.white
        resultMessage.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(resultMessage)
    }
    
    func resetGame() {
        lives = 3
        numOfBricksRemaining = 21
        ball.removeFromParent()
        paddle.removeFromParent()
        loseZone.removeFromParent()
        resultMessage.removeFromParent()
        livesRemaining.removeFromParent()
        showResult(result: "")
        showLives(lives: 0, clear: true)
        for brick in bricks {
            brick.removeFromParent()
        }
    }
    
    func createGame() {
        showLives(lives: lives, clear: false)
        createBackground()
        makeBall()
        makePaddle()
        createBricks()
        makeLoseZone()
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.applyImpulse(CGVector(dx: Int.random(in: -3...3), dy: 5))
    }
}
