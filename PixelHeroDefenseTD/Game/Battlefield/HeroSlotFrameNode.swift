//
//  HeroSlotFrameNode.swift
//  PixelHeroDefenseTD
//

import SpriteKit

/// Прямокутник слота: лише біла обводка, без заливки.
final class HeroSlotFrameNode: SKNode {
    private let shape: SKShapeNode
    private var isHighlighted = false
    private var dragDropTargetsActive = false

    init(size: CGSize) {
        let rect = CGRect(
            x: -size.width * 0.5,
            y: -size.height * 0.5,
            width: size.width,
            height: size.height
        )
        shape = SKShapeNode(rect: rect)
        shape.fillColor = .clear
        shape.strokeColor = .white
        shape.lineWidth = 2
        super.init()
        addChild(shape)
        applyAppearance()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    func updateBounds(size: CGSize) {
        let rect = CGRect(
            x: -size.width * 0.5,
            y: -size.height * 0.5,
            width: size.width,
            height: size.height
        )
        shape.path = CGPath(rect: rect, transform: nil)
    }

    func setHighlighted(_ on: Bool) {
        isHighlighted = on
        applyAppearance()
    }

    /// Усі слоти — нейтральна зона дропу під час перетягування героя.
    func setDragDropTargetsActive(_ active: Bool) {
        dragDropTargetsActive = active
        applyAppearance()
    }

    private func applyAppearance() {
        if dragDropTargetsActive {
            shape.fillColor = SKColor(red: 0.82, green: 0.86, blue: 0.90, alpha: 0.28)
            if isHighlighted {
                shape.strokeColor = SKColor(red: 0.38, green: 0.58, blue: 0.78, alpha: 0.95)
                shape.lineWidth = 3.2
            } else {
                shape.strokeColor = SKColor(white: 0.62, alpha: 0.5)
                shape.lineWidth = 2
            }
        } else {
            shape.fillColor = .clear
            shape.lineWidth = isHighlighted ? 2.8 : 2
            shape.strokeColor = isHighlighted ? SKColor(white: 1, alpha: 1) : SKColor(white: 1, alpha: 0.85)
        }
    }

    /// Під час хвилі рамки ховаються (лишаються лише для логіки тапу в сцені).
    func setSlotsVisible(_ visible: Bool) {
        alpha = visible ? 1 : 0
    }
}
