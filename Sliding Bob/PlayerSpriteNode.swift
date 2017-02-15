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
    
    var animation: SKAction?
    
    // MARK: Movement
    
    func beginWalkingAnimation(time: TimeInterval) {
        let textureAtlas = SKTextureAtlas(named: "player")
        let frames = ["p1_walk01", "p1_walk02", "p1_walk03","p1_walk04",
                      "p1_walk05", "p1_walk06", "p1_walk07", "p1_walk08",
                      "p1_walk09", "p1_walk10", "p1_walk11"].map({textureAtlas.textureNamed($0)})
        let animate = SKAction.animate(with: frames, timePerFrame: time)
        let animation = SKAction.repeatForever(animate)
        
        run(animation, withKey: "walking")
    }
    
    func beginJump() {
        if (self.action(forKey: "walking") != nil) {
            self.removeAction(forKey: "walking")
            let impulse = CGVector(dx: 0.0, dy: 40.0)
            self.texture = SKTexture(imageNamed: "p1_jump")
            self.physicsBody?.applyImpulse(impulse)
        } else {
            return
        }
    }
    
    func beginDuckWithSize(size: CGSize, movingForward fwd:Bool = false) {
        
        let neg = (fwd ? Double(0) : Double(-1))
        let duckingAction = SKAction.move(by:
            CGVector(dx: PLAYER_SPEED * 60 * neg, dy: 0), duration: DUCK_TIME)
        self.removeAction(forKey: "walking")
        self.texture = SKTexture(imageNamed: "p1_duck")
        self.size = size
        self.setDuckingBody()
        run(duckingAction, withKey: "ducking")
    }
    
    func endDuckWithSize(size: CGSize) {
        
        self.size = size
        self.setPhysicsBody()
        self.removeAction(forKey: "ducking")
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
}
