//
//  ObstacleSpriteNode.swift
//  Sliding Bob
//
//  Created by Ivan Aguilar on 2/15/17.
//  Copyright © 2017 Ivan Aguilar. All rights reserved.
//

import Foundation
import SpriteKit

class ObstacleSpriteNode: SKSpriteNode {
   
    // MARK: Properties
    
    var velocity = PLAYER_SPEED
    
    // MARK: PhysicsBody
    
    func setPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
        self.physicsBody?.collisionBitMask = PhysicsCategory.Floor | PhysicsCategory.Player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Player
    }
    
    // MARK: Initializations
    
    required init(imageNamed image: String, withSize size: CGSize) {
        let texture = SKTexture(imageNamed: image)
        super.init(texture: texture, color: .clear, size: size)
        setPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

}

class BlockSpriteNode: ObstacleSpriteNode {
    
    
    // MARK: Initializations 
    
    required init(imageNamed image: String, withSize size: CGSize) {
        super.init(imageNamed: image, withSize: size)
        self.name = "block"
    }
    
    init(inView view: SKView) {
        super.init(imageNamed: "boxAlt", withSize: CGSize(width: view.frame.height * 0.15, height: view.frame.height * 0.15))
        self.name = "block"
        self.physicsBody?.mass = 999999.99
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

}

class FlySpriteNode: ObstacleSpriteNode {
    
    
    
    // MARK: Movements
    
    func beginFlyingAnimation() {
        let textureAtlas = SKTextureAtlas(named: "fly")
        let frames = ["flyFly1", "flyFly2"].map({textureAtlas.textureNamed($0)})
        let animate = SKAction.animate(with: frames, timePerFrame: 0.2)
        let animation = SKAction.repeatForever(animate)
        
        run(animation, withKey: "fly_flying")
    }

    
    // MARK: Initializations
    
    required init(imageNamed image: String, withSize size: CGSize) {
        super.init(imageNamed: image, withSize: size)
        self.name = "fly"
    }
    
    
    init(inView view: SKView, withVelocity velocity: Double) {
        super.init(imageNamed: "flyFly1", withSize: CGSize(width: view.frame.height * 0.15, height: view.frame.height * 0.075))
        self.name = "fly"
        self.velocity = velocity
        self.physicsBody?.mass = 999999.99
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    

}
