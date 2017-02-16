//
//  GameScene.swift
//  Sliding Bob
//
//  Created by Ivan Aguilar on 2/15/17.
//  Copyright © 2017 Ivan Aguilar. All rights reserved.
//

import SpriteKit
import GameplayKit
import Foundation

// MARK: GAME CONSTANTS

let PLAYER_SPEED = 2.0
let PLAYER_SPEED_IDLE = 0.0
let PLAYER_SPEED_JUMP = -1.0
let PLAYER_WALK_SPEED = -2.0
let GRAVITY = -9.8
let WALK_SIZE = CGSize(width: 72.0/2, height: 97.0/2)
let STAND_SIZE = CGSize(width: 66.0/2, height: 92.0/2)
let DUCK_SIZE = CGSize(width: 72.0/2, height: 71.0/2)
let SLIDE_RUN = CGVector(dx: 20.0, dy: 0.0)
let DUCK_TIME = 0.8
let WALKING_TIME = 0.1

// MARK: Math Functions

func + (operand1: CGPoint, operand2: CGPoint) -> CGPoint {
    return CGPoint(x: operand1.x + operand2.x, y: operand1.y + operand2.y)
}

func - (operand1: CGPoint, operand2: CGPoint) -> CGPoint {
    return CGPoint(x: operand1.x - operand2.x, y: operand1.y - operand2.y)
}

func / (operand1: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: operand1.x / scalar, y: operand1.y / scalar )
}

func * (operand1: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: operand1.x * scalar, y: operand1.y / scalar )
}

private func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

private func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}


struct PhysicsCategory {
    static let None         : UInt32 = 0
    static let All          : UInt32 = UInt32.max
    static let Player       : UInt32 = 0b1
    static let DuckingPlayer: UInt32 = 0b10
    static let Floor        : UInt32 = 0b11
    static let Obstacle     : UInt32 = 0b100
}




class GameScene: SKScene, SKPhysicsContactDelegate, UIGestureRecognizerDelegate {
    
    // MARK: Properties
    
    private var floor: FloorSpriteNode?
    private var player: PlayerSpriteNode?
    private var background : SKSpriteNode?
    private var movingBackground: BackgroundSpriteNode?
    private var obstacles: [ObstacleSpriteNode] = []
    
    // MARK: SKNode Overrides
    
    override func addChild(_ node: SKNode) {
        super.addChild(node)
        if node.physicsBody?.categoryBitMask == PhysicsCategory.Obstacle {
            self.obstacles.append((node as? ObstacleSpriteNode)!)
        }
    }
    
    // MARK: SKScene Overrides
    
    override func didMove(to view: SKView) {
        self.setupBackground(view: view)
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: GRAVITY)
        self.physicsWorld.contactDelegate = self
        view.showsPhysics = true
        self.setupFloors()
        self.createPlayer()
        self.createWalls()
        self.player?.beginStanding()
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp(sender:)) )
        swipeUp.direction = .up
        swipeUp.delegate = self
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown(sender:)) )
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight(sender:)) )
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender: )))
        longPress.minimumPressDuration = 0.03
        view.addGestureRecognizer(longPress)
        
        //                run(SKAction.repeatForever(
        //                    SKAction.sequence([
        //                        SKAction.run({self.createFly(view: view, withVelocity: Double(random(min:2, max: 6)))}),
        //                        SKAction.wait(forDuration: 1.3)
        //                        ])
        //                ))
    }
    
    // MARK: UIGestureRecognizer Delegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.moveFloors()
        self.movePlayer()
        for obstacle in obstacles {
            moveAnObstacle(obstacle: obstacle, withSpeed: CGFloat(obstacle.velocity))
        }
    }
    
    
    // MARK: SKPhysicsContactDelegate
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var bodyOne: SKPhysicsBody
        var bodyTwo: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask {
            bodyOne = contact.bodyA
            bodyTwo = contact.bodyB
        } else {
            bodyOne = contact.bodyB
            bodyTwo = contact.bodyA
        }
        
        if ((bodyOne.categoryBitMask & PhysicsCategory.Floor != 0) &&
            (bodyTwo.categoryBitMask & PhysicsCategory.Player != 0)) {
            if let _ = bodyOne.node as? FloorSpriteNode,
                let player = bodyTwo.node as? PlayerSpriteNode {
                player.endJumping()
                player.beginStanding()
            }
        } else if ((bodyOne.categoryBitMask & PhysicsCategory.Obstacle != 0) &&
            (bodyTwo.categoryBitMask & PhysicsCategory.Player != 0)) {
            return
        }
    }
    
    
    
    private func playerContacted(player: PlayerSpriteNode, aboveObstacle obstacle: ObstacleSpriteNode) -> Bool {
        let playerX = player.position.x
        let obstacleX = obstacle.position.x
        let playerY = player.position.y
        let obstacleY = obstacle.position.y
        let playerWidth = player.size.width
        let obstacleHeight = obstacle.size.height
        
        if ((playerX + 2*playerWidth/3 > obstacleX) && (playerY > obstacleY + obstacleHeight/3)) {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Player
    
    func createPlayer() {
        self.player = PlayerSpriteNode(withSize: STAND_SIZE)
        self.player?.position = CGPoint(x:size.width * 0.2, y: (size.height * 0.2) + (self.player!.size.height/2))
        self.addChild(player!)
    }
    
    func movePlayer() {
        self.player?.position.x -= CGFloat((self.player?.velocity)!)
    }
    
    // MARK: Player Controls
    
    func swipedUp(sender: UISwipeGestureRecognizer) {
        print("swipe up")
        self.player?.endStanding()
        self.player?.endWalking()
        self.player?.beginJumping()
    }
    
    func swipedDown(sender: UISwipeGestureRecognizer) {
        if (self.player?.currentStatus != .Ducking){
            self.player?.endStanding()
            self.player?.endJumping()
            self.run(SKAction.sequence([
                SKAction.run {
                    self.player?.beginDucking()
                },
                SKAction.wait(forDuration: DUCK_TIME),
                SKAction.run {
                    self.player?.endDucking()
                    self.player?.beginStanding()
                }
                ]))
        }
    }
    
    func swipedRight(sender: UISwipeGestureRecognizer) {
        if ((self.player?.currentStatus != .Sliding)) {
            self.player?.endWalking()
            self.player?.endJumping()
            self.player?.endStanding()
            self.player?.beginSliding()
            self.run(SKAction.sequence([
                SKAction.run {
                    self.player?.beginWalking(time: WALKING_TIME/2)
                    self.player?.physicsBody?.applyImpulse(CGVector(dx: 25.0, dy: 0.0))
                },
                SKAction.wait(forDuration: 0.30),
                SKAction.run {
                    self.player?.endWalking()
                    self.player?.beginDucking()
                    self.player?.physicsBody?.applyImpulse(CGVector(dx: 15.0, dy: 0.0))
                },
                SKAction.wait(forDuration: DUCK_TIME),
                SKAction.run {
                    self.player?.endDucking()
                    self.player?.endSliding()
                },
                SKAction.run {
                    self.player?.beginStanding()
                }
                ]))
            
        }
    }
    
    func longPressed(sender: UITapGestureRecognizer) {
        if (sender.location(in: self.view).x > self.frame.width/2) {
            if(sender.state == .began) {
                print("long press began")
                self.player?.endStanding()
                self.player?.endDucking()
                self.player?.beginWalking(time: WALKING_TIME)
                self.player?.velocity = PLAYER_WALK_SPEED * 1.0
            } else if (sender.state == .ended) {
                self.player?.velocity = PLAYER_SPEED
                self.player?.endWalking()
                self.player?.beginStanding()
            }
            
        }
    }
    
    
    // MARK: Obstacle Generation
    
    func createBlock(view: SKView) {
        let block = BlockSpriteNode(inView: view)
        block.position = centerFromNode(node: block) + CGPoint(x: size.width * 0.8, y: size.height * 0.2)
        addChild(block)
    }
    
    func createFly(view: SKView, withVelocity velocity: Double) {
        let fly = FlySpriteNode(inView: view, withVelocity: velocity)
        fly.position = centerFromNode(node: fly) + CGPoint(x: 1.2 * size.width, y: size.height * 0.3)
        fly.beginFlyingAnimation()
        addChild(fly)
    }
    
    func moveAnObstacle(obstacle: ObstacleSpriteNode, withSpeed speed: CGFloat) {
        if let block = obstacle as? BlockSpriteNode {
            if block.position.x < -block.size.width {
                obstacles = obstacles.filter {
                    $0 != block
                }
                block.removeFromParent()
                return
            }
            block.position.x += -speed * 1.0
        } else if let fly = obstacle as? FlySpriteNode {
            if fly.position.x < -fly.size.width {
                obstacles = obstacles.filter {
                    $0 != fly
                }
                fly.removeFromParent()
                return
            }
            
            fly.position.x += -speed * 1.0
        } else {
            return
        }
    }
    
    // MARK: Environment
    
    func setupBackground(view: SKView) {
        background = SKSpriteNode(imageNamed: "background")
        background?.size = view.frame.size
        background?.zPosition = -1.0
        background?.position = centerFromNode(node: background!)
        addChild(background!)
    }
    
    func createWalls() {
        let left_wall = SKNode()
        let right_wall = SKNode()
        left_wall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0.0 , y: 0.0),
                                              to: CGPoint(x: 0.0 , y: self.frame.height))
        
        right_wall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: self.frame.width , y: 0.0),
                                               to: CGPoint(x: self.frame.width , y: self.frame.height))
        wallPhysicsSetup(wall: left_wall)
        wallPhysicsSetup(wall: right_wall)
        addChild(left_wall)
        addChild(right_wall)
    }
    
    func wallPhysicsSetup(wall: SKNode) {
        wall.physicsBody?.affectedByGravity = false
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.mass = 9999999.99
        wall.physicsBody?.categoryBitMask = PhysicsCategory.Floor
    }
    
    
    func setupFloors() {
        for i in 0...2 {
            floor = FloorSpriteNode(withSize: CGSize(width: size.width,
                                                     height: size.height * 0.2))
            floor?.position = centerFromNode(node: floor!) + CGPoint(x: floor!.size.width * CGFloat(i), y: 0.0)
            addChild(floor!)
        }
        
    }
    
    func moveFloors() {
        self.enumerateChildNodes(withName: "floor", using:
            {
                (node, error) in
                node.position = node.position + CGPoint(x: -PLAYER_SPEED, y: 0.0)
                if node.position.x < -node.frame.width {
                    node.position.x += node.frame.width * 3
                }
        }
        )
    }
    

    // MARK: Private Methods
    
    private func centerFromNode(node: SKSpriteNode) -> CGPoint{
        let size = node.size
        let position = node.position
        
        return position + CGPoint(x: size.width/2, y: size.height/2)
    }
    
}
