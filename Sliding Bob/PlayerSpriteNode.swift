//
//  PlayerSpriteNode.swift
//  Sliding Bob
//
//  Created by Ivan Aguilar on 2/15/17.
//  Copyright © 2017 Ivan Aguilar. All rights reserved.
//

import Foundation
import SpriteKit

class PlayerSpriteNode: SKSpriteNode {
    
    // MARK: Properties
    
    private var animation: SKAction?
    var currentStatus: CurrentStatus = .Idle
    var velocity = 0.0
    
    // MARK: Textures
    
    private let standTexture = SKTexture(imageNamed: "p1_stand")
    private let jumpTexture = SKTexture(imageNamed: "p1_jump")
    private let duckTexture = SKTexture(imageNamed: "p1_duck")
    private let textureAtlas = SKTextureAtlas(named: "player")
    private let frames = ["p1_walk01", "p1_walk02", "p1_walk03",
                          "p1_walk04", "p1_walk05", "p1_walk06",
                          "p1_walk07", "p1_walk08", "p1_walk09",
                          "p1_walk10", "p1_walk11"].map {
                            SKTextureAtlas(named: "player").textureNamed($0)
                            }
    
    
    // MARK: Actions
    
    func beginStanding() {
        if (self.currentStatus == .Idle) {
            self.currentStatus = .Standing
            self.texture = self.standTexture
            self.velocity = PLAYER_SPEED
        } else {
            return
        }
    }
    
    func endStanding() {
        if (self.currentStatus == .Standing) {
            self.currentStatus = .Idle
            self.velocity = PLAYER_SPEED_IDLE
        } else {
            return
        }
    }
    
    func beginWalking(time: TimeInterval) {
        if (self.currentStatus == .Idle) {
            let animate = SKAction.animate(with: self.frames, timePerFrame: time)
            let animation = SKAction.repeatForever(animate)
            
            self.run(animation, withKey: "walking")
        } else if (self.currentStatus == .Sliding) {
            let animate = SKAction.animate(with: self.frames, timePerFrame: time)
            let animation = SKAction.repeatForever(animate)
            self.run(animation, withKey: "walking")
        } else {
            return
        }
    }
    
    func endWalking() {
        if (self.currentStatus == .Walking) {
            self.currentStatus = .Idle
            self.removeAction(forKey: "walking")
        } else {
            return
        }
    }
    
    func beginJumping() {
        if (self.currentStatus == .Idle) {
            self.currentStatus = .Jumping
            self.texture = self.jumpTexture
            
            let impulse = CGVector(dx: 0.0, dy: 40.0)
            self.physicsBody?.applyImpulse(impulse)
        } else {
            return
        }
    }

    func endJumping() {
        if (self.currentStatus == .Jumping) {
            self.currentStatus = .Idle
        } else {
            return
        }
    }
    
    func beginDucking() {
        if (self.currentStatus == .Idle) {
            self.currentStatus = .Ducking
            self.texture = self.duckTexture
            self.size = DUCK_SIZE
            self.setDuckingBody()
        } else if (self.currentStatus == .Sliding) {
            self.texture = self.duckTexture
            self.size = DUCK_SIZE
            self.setDuckingBody()
        } else {
            return
        }
    }
    
    func endDucking() {
        if (self.currentStatus == .Ducking) {
            self.currentStatus = .Idle
            self.size = STAND_SIZE
            self.setPhysicsBody()
        } else if (self.currentStatus == .Sliding) {
            self.size = STAND_SIZE
            self.setPhysicsBody()
        } else {
            return
        }
    }
    
    func beginSliding() {
        if (self.currentStatus == .Idle) {
            self.currentStatus = .Sliding
            let slidingAction = SKAction.sequence([
                SKAction.applyImpulse(SLIDE_RUN, duration: 1.0),
                SKAction.run {
                    self.beginWalking(time: 0.05)
                },
                SKAction.wait(forDuration: 0.30),
                SKAction.run {
                    self.removeAction(forKey: "walking")
                },
                SKAction.run {
                    self.beginDucking()
                },
                SKAction.applyImpulse(SLIDE_RUN, duration: 1.0),
                SKAction.run {
                    self.endDucking()
                }
                ])
            self.run(slidingAction, withKey: "sliding")
        } else {
            return
        }
    }
    
    func endSliding() {
        if (self.currentStatus == .Sliding) {
            self.currentStatus = .Idle
            self.removeAction(forKey: "sliding")
        }
    }
        
    // MARK: PhysicsBody
    
    func setPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.isDynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.Player
        self.physicsBody?.collisionBitMask = PhysicsCategory.Floor | PhysicsCategory.Obstacle
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Floor
    }
    
    func setDuckingBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.DuckingPlayer
        self.physicsBody?.collisionBitMask = PhysicsCategory.Floor
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Floor
        
    }
    // MARK: Initializations
    
    init(withSize size: CGSize) {
        let texture = SKTexture(imageNamed: "p1_walk01")
        super.init(texture: texture, color: .clear, size: size)
        self.name = "player"
        setPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: Status Enum
    
    enum CurrentStatus {
        case Standing
        case Walking
        case Jumping
        case Ducking
        case Sliding
        case Idle
    }
    
}
