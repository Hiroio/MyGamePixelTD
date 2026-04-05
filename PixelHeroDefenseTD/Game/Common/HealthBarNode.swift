//
//  HealthBarNode.swift
//  PixelHeroDefenseTD
//

import SpriteKit

/// Мінімалістичний піксельний HP-бар (fill зліва).
final class HealthBarNode: SKNode {
    private let background = SKSpriteNode(color: .black.withAlphaComponent(0.55), size: CGSize(width: 36, height: 5))
    private let fill = SKSpriteNode(color: .white, size: CGSize(width: 34, height: 3))
    private let maxFillWidth: CGFloat = 34

    init(fillColor: SKColor) {
        super.init()
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        fill.anchorPoint = CGPoint(x: 0, y: 0.5)
        fill.color = fillColor
        fill.position = CGPoint(x: -maxFillWidth / 2, y: 0)
        addChild(background)
        addChild(fill)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setProgress(_ progress: CGFloat) {
        let p = min(max(progress, 0), 1)
        fill.xScale = p
    }
}
