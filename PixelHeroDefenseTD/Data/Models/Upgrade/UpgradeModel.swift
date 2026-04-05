//
//  UpgradeModel.swift
//  PixelHeroDefenseTD
//

import Foundation

struct HeroUpgrade: Identifiable, Sendable {
    let upgradeID: String
    var id: String { upgradeID }

    let name: String
    let description: String
    let icon: String
    let targetRole: UnitRole
    let rarity: UpgradeRarity
    /// Special / rare scaler: родина механіки. Для **basic / rare статів** залишається `nil`.
    let mechanicFamily: MechanicFamily?

    let stepDescription: String?
    let apply: @Sendable (inout HeroCombatStats) -> Void
    let step: @Sendable (inout HeroCombatStats) -> Void

    init(
        name: String,
        description: String,
        icon: String,
        targetRole: UnitRole,
        rarity: UpgradeRarity = .basic,
        mechanicFamily: MechanicFamily? = nil,
        upgradeID: String? = nil,
        stepDescription: String? = nil,
        apply: @escaping @Sendable (inout HeroCombatStats) -> Void,
        step: @escaping @Sendable (inout HeroCombatStats) -> Void = { _ in }
    ) {
        self.upgradeID = upgradeID ?? Self.defaultID(role: targetRole, name: name)
        self.name = name
        self.description = description
        self.icon = icon
        self.targetRole = targetRole
        self.rarity = rarity
        self.mechanicFamily = mechanicFamily
        self.stepDescription = stepDescription
        self.apply = apply
        self.step = step
    }

    private static func defaultID(role: UnitRole, name: String) -> String {
        let slug = name.lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .filter { $0.isLetter || $0.isNumber || $0 == "_" }
        return "\(role.rawValue)_\(slug)"
    }

    /// Rare картка «+10% до механіки» — показується лише коли механіка вже активна.
    var isRareMechanicScaler: Bool { rarity == .rare && mechanicFamily != nil }

    func applyToStats(_ stats: inout HeroCombatStats) {
        let key = name
        if rarity == .special {
            guard stats.upgradeStacks[key, default: 0] == 0 else { return }
            apply(&stats)
            stats.upgradeStacks[key, default: 0] = 1
            if let family = mechanicFamily {
                stats.unlockedMechanics.insert(family)
            }
            return
        }
        if stats.upgradeStacks[key, default: 0] == 0 {
            apply(&stats)
        } else {
            step(&stats)
        }
        stats.upgradeStacks[key, default: 0] += 1
    }
}
