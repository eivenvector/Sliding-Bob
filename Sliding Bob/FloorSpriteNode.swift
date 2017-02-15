//
//  FloorSpriteNode.swift
//  Sliding Bob
//
//  Created by Ivan Aguilar on 2/15/17.
//  Copyright © 2017 Ivan Aguilar. All rights reserved.
//

import Foundation
import SpriteKit

class FloorSpriteNode: SKSpriteNode {
    
    // MARK: PhysicsBody
    
    func setPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.Floor
        self.physicsBody?.collisionBitMask = PhysicsCategory.Player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Player
    }
    
    // MARK: Initializations

    init(withSize size: CGSize) {
        let texture = SKTexture(imageNamed: "tiled_floor")
        super.init(texture: texture, color: .clear, size: size)
        self.name = "floor"
        setPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}
