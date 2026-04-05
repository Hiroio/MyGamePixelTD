//
//  CoinPickupNode.swift
//  PixelHeroDefenseTD
//

import SpriteKit

enum CoinPickupNode {
    /// Монета злітає до героя; `onArrive` викликається перед видаленням вузла.
    static func spawn(
        in scene: SKScene,
        from worldPoint: CGPoint,
        to target: CGPoint,
        onArrive: @escaping () -> Void
    ) {
        let tex = SKTexture(imageNamed: "Coin")
        tex.filteringMode = .nearest
        let node = SKSpriteNode(texture: tex)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        node.setScale(0.45)
        node.position = worldPoint
        node.zPosition = 100
        scene.addChild(node)

        let mid = CGPoint(
            x: (worldPoint.x + target.x) * 0.5 + 40,
            y: (worldPoint.y + target.y) * 0.5 + 30
        )
        let c1 = SKAction.move(to: mid, duration: 0.18)
        c1.timingMode = .easeOut
        let c2 = SKAction.move(to: target, duration: 0.28)
        c2.timingMode = .easeIn
        let credit = SKAction.run(onArrive)
        let shrink = SKAction.scale(to: 0.15, duration: 0.08)
        let fade = SKAction.fadeOut(withDuration: 0.06)
        node.run(SKAction.sequence([c1, c2, credit, shrink, fade, .removeFromParent()]))
    }
}
