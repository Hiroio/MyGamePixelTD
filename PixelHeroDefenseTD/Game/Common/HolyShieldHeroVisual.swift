//
//  HolyShieldHeroVisual.swift
//  PixelHeroDefenseTD
//

import SpriteKit

/// Круг (blue, α 0.2) + тонкий бар щита над HP; показується лише коли `currentShield > 0`.
final class HolyShieldHeroVisual: SKNode {
    private let ring = SKShapeNode()
    private let barBackground = SKSpriteNode()
    private let barFill = SKSpriteNode()

    private let ringBaseRadius: CGFloat = 22
    private let barWidth: CGFloat = 30
    private let barBgHeight: CGFloat = 4
    private let barFillHeight: CGFloat = 2.5
    /// Трохи вище стандартного HP-бару героїв (y ≈ −40).
    private let barY: CGFloat = -33

    override init() {
        super.init()
        ring.fillColor = SKColor(red: 0.2, green: 0.45, blue: 1.0, alpha: 0.2)
        ring.strokeColor = .clear
        ring.zPosition = -7
        ring.position = .zero

        barBackground.color = SKColor.black.withAlphaComponent(0.45)
        barBackground.zPosition = 26
        barBackground.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        barFill.color = SKColor(red: 0.45, green: 0.85, blue: 1.0, alpha: 0.9)
        barFill.anchorPoint = CGPoint(x: 0, y: 0.5)
        barFill.zPosition = 27

        barBackground.position = CGPoint(x: 0, y: barY)
        barFill.position = CGPoint(x: -barWidth / 2, y: barY)

        addChild(ring)
        addChild(barBackground)
        addChild(barFill)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// `maxShield` — початкове значення за хвилю (для пропорції бара).
    func updatePresentation(currentShield: Double, maxShield: Double, displayScale: CGFloat) {
        let active = currentShield > 0 && maxShield > 0
        isHidden = !active

        guard active else { return }

        let s = max(0.35, displayScale)
        let r = ringBaseRadius * s
        ring.path = CGPath(ellipseIn: CGRect(x: -r, y: -r, width: r * 2, height: r * 2), transform: nil)

        let bw = barWidth * s
        let bh = barBgHeight * s
        let fh = barFillHeight * s
        barBackground.size = CGSize(width: bw + 2, height: bh)
        barBackground.position = CGPoint(x: 0, y: barY * s)

        barFill.size = CGSize(width: max(1, bw - 2), height: fh)
        barFill.position = CGPoint(x: -bw / 2, y: barY * s)
        let p = min(1, max(0, CGFloat(currentShield / maxShield)))
        barFill.xScale = p
    }
}
