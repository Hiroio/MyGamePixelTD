//
//  UpgradeManager.swift
//  PixelHeroDefenseTD
//

import Foundation

final class UpgradeManager {
    static let shared = UpgradeManager()

    private init() {}

    var archerUpgrade: [HeroUpgrade] { HeroUpgrade.archerUpgrades }
    var knightUpgrade: [HeroUpgrade] { HeroUpgrade.knightUpgrades }
    var mageUpgrade: [HeroUpgrade] { HeroUpgrade.mageUpgrades }

    /// Draft perk cards. За замовчуванням намагається включити одну **basic**; `specialOnly` — тільки **special** (без basic/rare).
    /// Special з `consumedSpecialIDs` випадають; rare «масштаб механіки» у звичайному драфті — лише якщо механіка доступна герою.
    func getRandom(
        for heroes: [UnitRole],
        upgraded: Bool,
        mageType: MageType?,
        consumedSpecialIDs: Set<String> = [],
        heroRoster: [HeroUnitModel] = [],
        specialOnly: Bool = false
    ) -> [HeroUpgrade] {
        let total = upgraded ? 4 : 3
        var allAvailable: [HeroUpgrade] = []
        let roles = Set(heroes)

        if roles.contains(.knight) {
            allAvailable.append(contentsOf: knightUpgrade)
        }
        if roles.contains(.archer) {
            allAvailable.append(contentsOf: archerUpgrade)
        }
        if roles.contains(.mage) {
            if let mageType {
                allAvailable.append(contentsOf: mageUpgrade + mageType.pathExtraUpgrades)
            } else {
                allAvailable.append(contentsOf: mageUpgrade + [
                    HeroUpgrade.lightningMage,
                    HeroUpgrade.fireMage,
                    HeroUpgrade.frostMage,
                ])
            }
        }

        let pool = allAvailable.filter { card in
            let notConsumed = !(card.rarity == .special && consumedSpecialIDs.contains(card.upgradeID))
            let scalerOK = !card.isRareMechanicScaler
                || mechanicScalerAllowed(card, roster: heroRoster, mageType: mageType)
            let tierOK = !specialOnly || card.rarity == .special
            return notConsumed && scalerOK && tierOK
        }
        guard !pool.isEmpty else { return [] }

        var remaining = pool.shuffled()
        var result: [HeroUpgrade] = []

        if specialOnly {
            while result.count < total, !remaining.isEmpty {
                let pick = remaining.randomElement()!
                result.append(pick)
                remaining.removeAll { $0.upgradeID == pick.upgradeID }
            }
        } else {
            if let basic = remaining.first(where: { $0.rarity == .basic }) {
                result.append(basic)
                remaining.removeAll { $0.upgradeID == basic.upgradeID }
            } else if let any = remaining.first {
                result.append(any)
                remaining.removeAll { $0.upgradeID == any.upgradeID }
            }

            while result.count < total, !remaining.isEmpty {
                let pick = remaining.randomElement()!
                result.append(pick)
                remaining.removeAll { $0.upgradeID == pick.upgradeID }
            }
        }

        return result
    }

    private func mechanicScalerAllowed(
        _ card: HeroUpgrade,
        roster: [HeroUnitModel],
        mageType: MageType?
    ) -> Bool {
        guard let family = card.mechanicFamily else { return true }
        switch family {
        case .mageLightning:
            return mageType == nil || mageType == .lightning
        case .mageFire:
            return mageType == .fire
        case .mageFrost:
            return mageType == .frost
        default:
            return roster.first(where: { $0.role == card.targetRole })?.stats.unlockedMechanics.contains(family) ?? false
        }
    }
}
