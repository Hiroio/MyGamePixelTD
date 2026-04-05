//
//  GameBalanceConfig.swift
//  PixelHeroDefenseTD
//
//  Central place for gameplay tuning values.
//

import Foundation

enum GameBalanceConfig {
    // MARK: - Waves

    /// Enemies per wave: starts at 10 and grows linearly.
    static func enemyCount(forWave wave: Int) -> Int {
        let w = max(1, wave)
        return max(1, 10 + 5 * (w - 1))
    }

    // MARK: - Spawn Timing

    /// Initial delay before early spawns.
    static let spawnFirstDelaySeconds: TimeInterval = 0.9
    /// Interval reduction after each spawn in the same wave.
    static let spawnIntervalDecrementSeconds: TimeInterval = 0.055
    /// Hard floor for spawn interval.
    static let spawnMinimumIntervalSeconds: TimeInterval = 0.18

    /// Interval for the next spawn after N spawns already done.
    static func spawnIntervalAfter(spawnsAlreadyDone: Int) -> TimeInterval {
        let base = spawnFirstDelaySeconds - spawnIntervalDecrementSeconds * Double(max(0, spawnsAlreadyDone))
        return max(spawnMinimumIntervalSeconds, base)
    }

    // MARK: - Enemy Scaling

    /// Multiplier applied to base HP by wave.
    static func enemyHPMultiplier(forWave wave: Int) -> Double {
        1.0 + 0.25 * Double(max(0, wave - 1))
    }

    /// Flat damage bonus added to baseDamage.
    static func enemyDamageBonus(forWave wave: Int) -> Double {
        0.20 * Double(max(0, wave - 1))
    }

    /// Flat moveSpeed bonus added per wave.
    static func enemyMoveSpeedBonus(forWave wave: Int) -> Double {
        0.025 * Double(max(0, wave - 1))
    }

    // MARK: - Economy
    static let startingCoins: Int = 65
    /// Hiring cost for one hero in an empty slot.
    static let heroHireCost: Int = 50

    // MARK: - Hero Upgrades

    static let heroUpgradeBaseCost: Int = 25

    /// Next level cost formula: base * currentLevel.
    static func heroUpgradeCost(currentLevel: Int) -> Int {
        max(1, heroUpgradeBaseCost) * max(1, currentLevel)
    }

    static let heroAttackSpeedBonusPerLevel: Double = 0.07
    static let heroHPBonusRatioPerLevel: Double = 0.15
    static let heroDamageBonusRatioPerLevel: Double = 0.2

    /// Hero levels that trigger perk choice.
    static func isHeroPerkMilestoneLevel(_ level: Int) -> Bool {
        level > 0 && level % 6 == 0
    }

    /// Індекс щойно завершеної хвилі, після якої показується драфт **лише** з Special (після 3 слайм-хвиль).
    static let specialOnlyPerkAfterCompletedWave: Int = 3

    /// Completed wave indexes that trigger perk choice UI.
    static func isPerkChoiceRound(_ waveNumber: Int) -> Bool {
        if waveNumber == specialOnlyPerkAfterCompletedWave { return true }
        return waveNumber >= 10 && waveNumber % 10 == 0
    }

    /// Після `specialOnlyPerkAfterCompletedWave` гравець обирає тільки Special-картки.
    static func isSpecialOnlyPerkRound(_ completedWaveIndex: Int) -> Bool {
        completedWaveIndex == specialOnlyPerkAfterCompletedWave
    }
}
