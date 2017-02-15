//
//  BackgroundSpriteNode.swift
//  Sliding Bob
//
//  Created by Ivan Aguilar on 2/15/17.
//  Copyright © 2017 Ivan Aguilar. All rights reserved.
//

import Foundation
import SpriteKit

class BackgroundSpriteNode: SKSpriteNode {
    
    
    // MARK: Initializations
    
    init(imageNamed image: String, withSize size: CGSize) {
        let texture = SKTexture(imageNamed: image)
        super.init(texture: texture, color: .clear, size: size)
        self.zPosition = -0.5
        self.name = "moving_background"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}
