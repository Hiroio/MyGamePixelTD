//
//  UpgradeModel.swift
//  PixelHeroDefenseTD
//
//  Created by user on 25.03.2026.
//

import Foundation

struct HeroUpgrade: Identifiable, Sendable {
    let id: UUID
    let name: String
    let description: String
    let icon: String
    let targetRole: UnitRole
    let stepDescription: String?
    let apply: @Sendable (inout HeroCombatStats) -> Void
    let step: @Sendable (inout HeroCombatStats) -> Void

    init(
        name: String,
        description: String,
        icon: String,
        targetRole: UnitRole,
        stepDescription: String? = nil,
        apply: @escaping @Sendable (inout HeroCombatStats) -> Void,
        step: @escaping @Sendable (inout HeroCombatStats) -> Void = { _ in }
    ) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.icon = icon
        self.targetRole = targetRole
        self.stepDescription = stepDescription
        self.apply = apply
        self.step = step
    }

    func applyToStats(_ stats: inout HeroCombatStats) {
        let key = name
        if stats.upgradeStacks[key, default: 0] == 0 {
            apply(&stats)
        } else {
            step(&stats)
        }
        stats.upgradeStacks[key, default: 0] += 1
    }
}
