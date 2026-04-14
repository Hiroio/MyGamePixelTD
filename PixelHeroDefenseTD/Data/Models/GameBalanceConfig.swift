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
    static let heroAttackSpeedBonusPerLevel: Double = 0.05
    static let heroHPBonusRatioPerLevel: Double = 0.15
    static let heroDamageBonusRatioPerLevel: Double = 0.15
    /// Рівні, після яких драфт rare/special зі зниженим шансом special (як хвилі кратні 6).
    static func isHeroPerkMilestoneLevel(_ level: Int) -> Bool {
        level > 0 && level % 5 == 0
    }

    /// Після цієї завершеної хвилі драфт тільки з Special (якщо лишились — інакше rare / standard).
    static let specialOnlyPerkAfterCompletedWave: Int = 3

    /// Завершена хвиля кратна 6 і не бос (5/10/15/20) → змішаний драфт rare + special.
    static func isMixedRareSpecialPerkRound(_ completedWaveIndex: Int) -> Bool {
        guard completedWaveIndex % 6 == 0 else { return false }
        return completedWaveIndex % 10 != 0
    }
    /// Ймовірність обрати special у змішаному драфті (на кожну картку окремо).
    static let perkMixedSpecialChance: Double = 0.22
    /// Монети за пропуск драфту перку: `max(completedWave * 4, 15)`.
    static func perkSkipCoinReward(completedWaveIndex: Int) -> Int {
        max(completedWaveIndex * 5, 15)
    }
    /// Скільки реролів драфту за одне вікно (0 після використання).
    static let perkDraftRerollsPerWindow: Int = 1
}
