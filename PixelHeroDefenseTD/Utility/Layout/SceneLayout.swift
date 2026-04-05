//
//  SceneLayout.swift
//  PixelHeroDefenseTD
//

import CoreGraphics

enum SceneLayout {
    static func heroDisplayScale(for sceneHeight: CGFloat, logicalFrame: CGFloat = 100) -> CGFloat {
        let targetHeight = sceneHeight * 0.20
        return max(0.01, targetHeight / logicalFrame)
    }

    static func enemyDisplayScale(for sceneHeight: CGFloat, logicalFrame: CGFloat = 100) -> CGFloat {
        let targetHeight = sceneHeight * 0.20
        return max(0.01, targetHeight / logicalFrame)
    }

    static func heroLaneY(for sceneSize: CGSize) -> CGFloat {
        -sceneSize.height * 0.33
    }

    static let heroSlotCount = 6

    /// Розмір прямокутника слота (компактна сітка).
    static func heroSlotSize(in sceneSize: CGSize) -> CGSize {
        let w = min(64, sceneSize.width * 0.17)
        let h = min(76, sceneSize.height * 0.13)
        return CGSize(width: w, height: h)
    }

    /// Центр слота: два ряди по 3 (0…2 верхній, 3…5 нижній).
    static func heroSlotCenter(slotIndex: Int, in sceneSize: CGSize) -> CGPoint {
        let idx = min(max(slotIndex, 0), heroSlotCount - 1)
        let col = idx % 3
        let row = idx / 3
        let slotW = heroSlotSize(in: sceneSize).width
        let spacingX = slotW + 10
        let rowGap = heroSlotSize(in: sceneSize).height + 9
        // Трохи вниз, щоб сітка виглядала природніше.
        let baseY = -sceneSize.height * 0.35
        let x = (CGFloat(col) - 1) * spacingX
        let y = baseY + (row == 0 ? rowGap * 0.5 : -rowGap * 0.5)
        return CGPoint(x: x, y: y)
    }

    static func heroSlotBounds(slotIndex: Int, in sceneSize: CGSize) -> CGRect {
        let c = heroSlotCenter(slotIndex: slotIndex, in: sceneSize)
        let s = heroSlotSize(in: sceneSize)
        return CGRect(
            x: c.x - s.width * 0.5,
            y: c.y - s.height * 0.5,
            width: s.width,
            height: s.height
        )
    }

    static func enemySpawnY(for sceneSize: CGSize) -> CGFloat {
        sceneSize.height * 0.60
    }

    /// Позиція барикади перед сіткою героїв.
    static func barricadePoint(in sceneSize: CGSize) -> CGPoint {
        CGPoint(x: 0, y: heroLaneY(for: sceneSize) + sceneSize.height * 0.16)
    }

    /// Точка утримання melee-боса (центр поля бою).
    static func bossHoldPoint(in sceneSize: CGSize) -> CGPoint {
        CGPoint(x: 0, y: sceneSize.height * 0.10)
    }

    static func combatReachMultiplier(for sceneHeight: CGFloat) -> CGFloat {
        max(3.0, sceneHeight / 220.0)
    }

    static func grassTileWorldSize(for sceneSize: CGSize) -> CGFloat {
        max(40, sceneSize.height * 0.10)
    }
}
