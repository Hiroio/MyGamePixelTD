//
//  UpgradeData.swift
//  PixelHeroDefenseTD
//

import Foundation

// MARK: - Core stat lines (+5% basic / +10% rare, одна величина за картку)

private enum CoreStatLine: CaseIterable {
    case damage, attackSpeed, hp, defense, range

    var titleBasic: String {
        switch self {
        case .damage: return "+5% Damage"
        case .attackSpeed: return "+5% Attack Speed"
        case .hp: return "+5% Max HP"
        case .defense: return "+5% Damage Reduction"
        case .range: return "+5% Range"
        }
    }

    var titleRare: String {
        switch self {
        case .damage: return "+10% Damage"
        case .attackSpeed: return "+10% Attack Speed"
        case .hp: return "+10% Max HP"
        case .defense: return "+10% Damage Reduction"
        case .range: return "+10% Range"
        }
    }

    func applyBasic(_ s: inout HeroCombatStats) {
        switch self {
        case .damage: s.baseDamage *= 1.05
        case .attackSpeed: s.attackSpeed *= 1.05
        case .hp: s.baseHP *= 1.05
        case .defense: s.damageReduction = min(0.75, s.damageReduction + 0.05)
        case .range: s.range *= 1.05
        }
    }

    func applyRare(_ s: inout HeroCombatStats) {
        switch self {
        case .damage: s.baseDamage *= 1.10
        case .attackSpeed: s.attackSpeed *= 1.10
        case .hp: s.baseHP *= 1.10
        case .defense: s.damageReduction = min(0.75, s.damageReduction + 0.10)
        case .range: s.range *= 1.10
        }
    }

    func icon(for role: UnitRole) -> String {
        switch (self, role) {
        case (.damage, .knight): return "Berserk"
        case (.attackSpeed, .knight): return "Bouler"
        case (.hp, .knight): return "Cleve"
        case (.defense, .knight): return "HeavyArmor"
        case (.range, .knight): return "LongBow"
        case (.damage, .archer): return "HeavyArrows"
        case (.attackSpeed, .archer): return "FocusShot"
        case (.hp, .archer): return "HeavyArmor"
        case (.defense, .archer): return "HeavyArmor"
        case (.range, .archer): return "LongBow"
        case (.damage, .mage): return "Staff"
        case (.attackSpeed, .mage): return "Staff"
        case (.hp, .mage): return "ThirdEye"
        case (.defense, .mage): return "HeavyArmor"
        case (.range, .mage): return "ThirdEye"
        }
    }
}

private func roleTitle(_ role: UnitRole) -> String {
    switch role {
    case .knight: return "Knight"
    case .archer: return "Archer"
    case .mage: return "Mage"
    }
}

private func coreStatUpgrades(for role: UnitRole) -> [HeroUpgrade] {
    CoreStatLine.allCases.flatMap { line -> [HeroUpgrade] in
        let prefix = roleTitle(role)
        let basic = HeroUpgrade(
            name: "\(prefix) — \(line.titleBasic)",
            description: "Increases one core stat.",
            icon: line.icon(for: role),
            targetRole: role,
            rarity: .basic,
            stepDescription: "Next pick: same bonus again.",
            apply: { line.applyBasic(&$0) },
            step: { line.applyBasic(&$0) }
        )
        let rare = HeroUpgrade(
            name: "\(prefix) — \(line.titleRare)",
            description: "Stronger core stat bonus.",
            icon: line.icon(for: role),
            targetRole: role,
            rarity: .rare,
            stepDescription: "Next pick: same bonus again.",
            apply: { line.applyRare(&$0) },
            step: { line.applyRare(&$0) }
        )
        return [basic, rare]
    }
}

// MARK: - HeroUpgrade pools

extension HeroUpgrade {
    static var knightUpgrades: [HeroUpgrade] {
        coreStatUpgrades(for: .knight) + knightSpecials + knightRareMechanicScalers
    }

    static var archerUpgrades: [HeroUpgrade] {
        coreStatUpgrades(for: .archer) + archerSpecials + archerRareMechanicScalers
    }

    static var mageUpgrades: [HeroUpgrade] {
        coreStatUpgrades(for: .mage) + mageRareMechanicScalers
    }

    // MARK: Knight — special

    private static let knightSpecials: [HeroUpgrade] = [
        HeroUpgrade(
            name: "Cleave",
            description: "Primary target + splash. Radius 10. Damage −15%.",
            icon: "Cleve",
            targetRole: .knight,
            rarity: .special,
            mechanicFamily: .cleave,
            apply: {
                $0.enemyTarget = 1
                $0.splashRadius = max($0.splashRadius, 10)
                $0.baseDamage *= 0.85
            },
            step: { _ in }
        ),
        HeroUpgrade(
            name: "Thorns",
            description: "Reflect 10% of damage taken to attackers.",
            icon: "Thorns",
            targetRole: .knight,
            rarity: .special,
            mechanicFamily: .thorns,
            apply: { $0.thornsPercentage += 0.1 },
            step: { _ in }
        ),
        HeroUpgrade(
            name: "Heavy Armor",
            description: "−20% damage taken. −10% attack speed.",
            icon: "HeavyArmor",
            targetRole: .knight,
            rarity: .special,
            mechanicFamily: .plateArmor,
            apply: {
                $0.damageReduction = min(0.75, $0.damageReduction + 0.2)
                $0.attackSpeed *= 0.9
            },
            step: { _ in }
        ),
        HeroUpgrade(
            name: "Enraged",
            description: "Below 30% HP: faster attacks (strength scales with upgrades).",
            icon: "Enrage",
            targetRole: .knight,
            rarity: .special,
            mechanicFamily: .enraged,
            apply: {
                $0.isEnragedActive = 0.3
                $0.enrageAttackSpeedMultiplier = 1.5
            },
            step: { _ in }
        ),
        HeroUpgrade(
            name: "Heavy Blows",
            description: "+1.0 knockback on hits.",
            icon: "Bouler",
            targetRole: .knight,
            rarity: .special,
            mechanicFamily: .knightKnockback,
            apply: { $0.knockback += 1.0 },
            step: { _ in }
        ),
    ]

    private static let knightRareMechanicScalers: [HeroUpgrade] = [
        HeroUpgrade(
            name: "Cleave — Wider Arc",
            description: "Splash radius +10%.",
            icon: "Cleve",
            targetRole: .knight,
            rarity: .rare,
            mechanicFamily: .cleave,
            stepDescription: "Next: +10% splash radius again.",
            apply: { $0.splashRadius *= 1.1 },
            step: { $0.splashRadius *= 1.1 }
        ),
        HeroUpgrade(
            name: "Thorns — Barbed",
            description: "Thorns reflect +10%.",
            icon: "Thorns",
            targetRole: .knight,
            rarity: .rare,
            mechanicFamily: .thorns,
            stepDescription: "Next: +10% thorns again.",
            apply: { $0.thornsPercentage *= 1.1 },
            step: { $0.thornsPercentage *= 1.1 }
        ),
        HeroUpgrade(
            name: "Plate — Tempered",
            description: "Damage reduction +10% (multiplicative, capped).",
            icon: "HeavyArmor",
            targetRole: .knight,
            rarity: .rare,
            mechanicFamily: .plateArmor,
            stepDescription: "Next: strengthen plate again.",
            apply: { $0.damageReduction = min(0.75, $0.damageReduction * 1.1) },
            step: { $0.damageReduction = min(0.75, $0.damageReduction * 1.1) }
        ),
        HeroUpgrade(
            name: "Enrage — Bloodrush",
            description: "Enrage attack-speed bonus +10%.",
            icon: "Enrage",
            targetRole: .knight,
            rarity: .rare,
            mechanicFamily: .enraged,
            stepDescription: "Next: stronger bloodrush.",
            apply: { $0.enrageAttackSpeedMultiplier *= 1.1 },
            step: { $0.enrageAttackSpeedMultiplier *= 1.1 }
        ),
        HeroUpgrade(
            name: "Heavy Blows — Ram",
            description: "Knockback +10%.",
            icon: "Bouler",
            targetRole: .knight,
            rarity: .rare,
            mechanicFamily: .knightKnockback,
            stepDescription: "Next: +10% knockback again.",
            apply: { $0.knockback *= 1.1 },
            step: { $0.knockback *= 1.1 }
        ),
    ]

    // MARK: Archer — special

    private static let archerSpecials: [HeroUpgrade] = [
        HeroUpgrade(
            name: "Chain Shot",
            description: "Arrows bounce to 2 extra targets (−12% damage).",
            icon: "ChainShot",
            targetRole: .archer,
            rarity: .special,
            mechanicFamily: .chainShot,
            apply: {
                $0.bounceCount += 2
                $0.baseDamage *= 0.88
            },
            step: { _ in }
        ),
        HeroUpgrade(
            name: "Freezing Bow",
            description: "Hits slow enemies by 20% for 2s.",
            icon: "FreezingBow",
            targetRole: .archer,
            rarity: .special,
            mechanicFamily: .freezingBow,
            apply: { $0.slownessEffect += 0.2 },
            step: { _ in }
        ),
        HeroUpgrade(
            name: "Multi Shot",
            description: "+1 target per salvo. −10% damage.",
            icon: "MultiShot",
            targetRole: .archer,
            rarity: .special,
            mechanicFamily: .multiShot,
            apply: {
                $0.enemyTarget += 1
                $0.baseDamage *= 0.9
            },
            step: { _ in }
        ),
        HeroUpgrade(
            name: "Keen Aim",
            description: "Far targets (>50): +15% damage.",
            icon: "FocusShot",
            targetRole: .archer,
            rarity: .special,
            mechanicFamily: .archerFocus,
            apply: { $0.focusDistanceBonus += 0.15 },
            step: { _ in }
        ),
    ]

    private static let archerRareMechanicScalers: [HeroUpgrade] = [
        HeroUpgrade(
            name: "Chain — Extra Link",
            description: "+1 bounce target.",
            icon: "ChainShot",
            targetRole: .archer,
            rarity: .rare,
            mechanicFamily: .chainShot,
            stepDescription: "Next: +1 bounce again.",
            apply: { $0.bounceCount += 1 },
            step: { $0.bounceCount += 1 }
        ),
        HeroUpgrade(
            name: "Freeze — Deep Chill",
            description: "Slow strength +10%.",
            icon: "FreezingBow",
            targetRole: .archer,
            rarity: .rare,
            mechanicFamily: .freezingBow,
            stepDescription: "Next: +10% slow again.",
            apply: { $0.slownessEffect *= 1.1 },
            step: { $0.slownessEffect *= 1.1 }
        ),
        HeroUpgrade(
            name: "Multi — Volley Drill",
            description: "Damage +10% (offsets spread).",
            icon: "MultiShot",
            targetRole: .archer,
            rarity: .rare,
            mechanicFamily: .multiShot,
            stepDescription: "Next: +10% damage again.",
            apply: { $0.baseDamage *= 1.1 },
            step: { $0.baseDamage *= 1.1 }
        ),
        HeroUpgrade(
            name: "Keen Aim — Deadeye",
            description: "Long-range bonus +10%.",
            icon: "FocusShot",
            targetRole: .archer,
            rarity: .rare,
            mechanicFamily: .archerFocus,
            stepDescription: "Next: +10% focus bonus again.",
            apply: { $0.focusDistanceBonus *= 1.1 },
            step: { $0.focusDistanceBonus *= 1.1 }
        ),
    ]

    // MARK: Mage — lightning path (single special)

    /// Базова блискавка: один special з ланцюгом (bounce + knockback), легкий обмін шкоди на швидкість.
    static let lightningMage: HeroUpgrade = HeroUpgrade(
        name: "Lightning Mage",
        description: "Chain lightning: +1 bounce, +1.0 knockback. −5% damage, +10% attack speed.",
        icon: "LightningMage",
        targetRole: .mage,
        rarity: .special,
        mechanicFamily: .mageLightning,
        apply: {
            $0.baseDamage *= 0.95
            $0.attackSpeed *= 1.10
            $0.knockback += 1.0
            $0.bounceCount += 1
        },
        step: { _ in }
    )

    static let fireMage: HeroUpgrade = HeroUpgrade(
        name: "Fire Mage",
        description: "Fireball AoE. Radius 15. −5% attack speed. 10% damage",
        icon: "FireMage",
        targetRole: .mage,
        rarity: .special,
        mechanicFamily: .mageFire,
        apply: {
            $0.mageType = .fire
			 $0.baseDamage *= 1.1
            $0.attackSpeed *= 0.95
            $0.splashRadius = max($0.splashRadius, 15)
        },
        step: { _ in }
    )

    static let frostMage: HeroUpgrade = HeroUpgrade(
        name: "Frost Mage",
        description: "Frost shards AoE. Radius 20, strong slow. −5% attack speed.",
        icon: "FrostMage",
        targetRole: .mage,
        rarity: .special,
        mechanicFamily: .mageFrost,
        apply: {
            $0.mageType = .frost
            $0.attackSpeed *= 0.95
            $0.splashRadius = max($0.splashRadius, 20)
            $0.slownessEffect = max($0.slownessEffect, 0.5)
        },
        step: { _ in }
    )

    private static let mageRareMechanicScalers: [HeroUpgrade] = [
        HeroUpgrade(
            name: "Lightning — Forked Path",
            description: "+1 chain bounce.",
            icon: "LightningMage",
            targetRole: .mage,
            rarity: .rare,
            mechanicFamily: .mageLightning,
            stepDescription: "Next: +1 bounce again.",
            apply: { $0.bounceCount += 1 },
            step: { $0.bounceCount += 1 }
        ),
        HeroUpgrade(
            name: "Lightning — Thunder Grip",
            description: "+0.5 knockback on hits.",
            icon: "LightningMage",
            targetRole: .mage,
            rarity: .rare,
            mechanicFamily: .mageLightning,
            stepDescription: "Next: +0.5 knockback again.",
            apply: { $0.knockback += 0.5 },
            step: { $0.knockback += 0.5 }
        ),
        HeroUpgrade(
            name: "Fire — Intense Blaze",
            description: "Fire splash & damage +10%.",
            icon: "FireMage",
            targetRole: .mage,
            rarity: .rare,
            mechanicFamily: .mageFire,
            stepDescription: "Next: +10% again.",
            apply: {
                $0.splashRadius *= 1.1
                $0.baseDamage *= 1.1
            },
            step: {
                $0.splashRadius *= 1.1
                $0.baseDamage *= 1.1
            }
        ),
        HeroUpgrade(
            name: "Frost — Wider Chill",
            description: "Frost radius +10%.",
            icon: "FrostMage",
            targetRole: .mage,
            rarity: .rare,
            mechanicFamily: .mageFrost,
            stepDescription: "Next: +10% radius again.",
            apply: { $0.splashRadius *= 1.1 },
            step: { $0.splashRadius *= 1.1 }
        ),
        HeroUpgrade(
            name: "Frost — Bitter Cold",
            description: "Slow strength +10%.",
            icon: "FrostMage",
            targetRole: .mage,
            rarity: .rare,
            mechanicFamily: .mageFrost,
            stepDescription: "Next: +10% slow again.",
            apply: { $0.slownessEffect *= 1.1 },
            step: { $0.slownessEffect *= 1.1 }
        ),
    ]
}
