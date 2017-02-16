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
    
    var currentStatus: CurrentStatus = .Idle
    var velocity = 0.0
    
    // MARK: Textures
    
    private let standTexture = SKTexture(imageNamed: "p1_stand")
    private let jumpTexture = SKTexture(imageNamed: "p1_jump")
    private let duckTexture = SKTexture(imageNamed: "p1_duck")
    private let textureAtlas = SKTextureAtlas(named: "player")
    private let frames = ["p1_walk01", "p1_walk02", "p1_walk03",
                          "p1_walk04", "p1_walk05"].map {
                            SKTextureAtlas(named: "player").textureNamed($0)
                            }
    
    
    // MARK: Actions
    
    func beginStanding() {
        if (self.currentStatus == .Idle) {
            print("began standing called")
            self.currentStatus = .Standing
            self.texture = self.standTexture
            self.size = STAND_SIZE
            self.velocity = PLAYER_SPEED
        } else {
            return
        }
    }
    
    func endStanding() {
        if (self.currentStatus == .Standing) {
            print("end standing called")
            self.currentStatus = .Idle
            self.velocity = PLAYER_SPEED_IDLE
        } else {
            return
        }
    }

    func beginWalking(time: TimeInterval) {
        if (self.currentStatus == .Idle)  {
            print("beginWalking called")
            self.currentStatus = .Walking
            self.size = WALK_SIZE
            let animate = SKAction.animate(with: self.frames, timePerFrame: time)
            let animation = SKAction.repeat(animate, count: 1)
            
            self.run(animation, withKey: "walking")
        } else if (self.currentStatus == .Sliding) {
            print("beginWalking called")
            self.size = WALK_SIZE
            let animate = SKAction.animate(with: self.frames, timePerFrame: time)
            let animation = SKAction.repeat(animate, count: 1)
            self.run(animation, withKey: "walking")
        } else {
            return
        }
    }
    
    func endWalking() {
        if (self.currentStatus == .Walking) {
            print("endWalking called")
            self.velocity = PLAYER_SPEED_IDLE
            self.currentStatus = .Idle
            self.removeAction(forKey: "walking")
            self.removeAction(forKey: "walkingAction")
        } else {
            return
        }
    }
    
    func beginJumping() {
        if (self.currentStatus == .Idle) {
            print("beginJumping called")
            self.currentStatus = .Jumping
            self.texture = self.jumpTexture
            self.velocity = PLAYER_SPEED_JUMP
            let impulse = CGVector(dx: 0.0, dy: 40.0)
            self.physicsBody?.applyImpulse(impulse)
        } else {
            return
        }
    }

    func endJumping() {
        if (self.currentStatus == .Jumping) {
            print("endJumping called")
            self.currentStatus = .Idle
            self.velocity = PLAYER_SPEED_IDLE
        } else {
            return
        }
    }
    
    func beginDucking() {
        if (self.currentStatus == .Idle) {
            print("beginDucking called")
            self.currentStatus = .Ducking
            self.texture = self.duckTexture
            self.velocity = PLAYER_SPEED
            self.size = DUCK_SIZE
            self.setDuckingBody()
        } else if (self.currentStatus == .Sliding) {
            print("beginDucking called")
            self.texture = self.duckTexture
            self.velocity = PLAYER_SPEED_IDLE
            self.size = DUCK_SIZE
            self.setDuckingBody()
        } else {
            return
        }
    }
    
    func endDucking() {
        if (self.currentStatus == .Ducking) {
            print("endDucking called")
            self.currentStatus = .Idle
            self.size = STAND_SIZE
            self.setPhysicsBody()
        } else if (self.currentStatus == .Sliding) {
            print("endDuckign called")
            self.size = STAND_SIZE
            self.setPhysicsBody()
        } else {
            return
        }
    }
    
    func beginSliding() {
        if (self.currentStatus == .Idle) {
            print("beginSliding called")
            self.currentStatus = .Sliding
        } else {
            return
        }
    }
    
    func endSliding() {
        if (self.currentStatus == .Sliding) {
            print("endSliding called")
            self.currentStatus = .Idle
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
        super.init(texture: self.standTexture, color: .clear, size: size)
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
