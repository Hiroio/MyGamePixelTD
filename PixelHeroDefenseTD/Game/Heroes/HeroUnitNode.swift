//
//  HeroUnitNode.swift
//  PixelHeroDefenseTD
//
//  Єдиний інтерфейс для різних героїв (лицар/лучник).
//

import Foundation
import SpriteKit

protocol HeroUnitNode: AnyObject {
    var unitModel: HeroUnitModel { get }
    var isAlive: Bool { get }
    var currentHP: Double { get }

    var combatRange: CGFloat { get }
    var damagePerHit: Double { get }
    var maxEnemyTargets: Int { get }

    func updateTick(deltaTime: TimeInterval)
    func updateScale(forSceneHeight height: CGFloat)

    func applyModel(_ model: HeroUnitModel, healToFull: Bool)
    @discardableResult func applyDamage(_ value: Double) -> Bool

    func playUpgradeFeedback()

    /// Візуальний радіус атаки для HUD. Має бути не клікабельним.
    func setPanelAttackRangeVisible(_ visible: Bool, radius: CGFloat)

    /// Виконує атаку по вже відфільтрованих цілях (в межах дальності).
    func attack(with targets: [BaseEnemyNode], in scene: GameScene)
}

