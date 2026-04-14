//
//  UpgradeManager.swift
//  PixelHeroDefenseTD
//

import Foundation

/// Режим драфту перків після хвилі / рівня.
enum PerkDraftMode: Equatable, Sendable {
    /// Basic + rare, без special.
    case standard
    /// Лише special (хвиля 3). Якщо special не лишилось — лише rare, інакше повний standard.
    case specialOnly
    /// Rare + доступні special; на кожну картку ймовірність `specialChance` обрати special.
    case mixedRareSpecial(specialChance: Double)
}

final class UpgradeManager {
    static let shared = UpgradeManager()

    private init() {}

    var archerUpgrade: [HeroUpgrade] { HeroUpgrade.archerUpgrades }
    var knightUpgrade: [HeroUpgrade] { HeroUpgrade.knightUpgrades }
    var mageUpgrade: [HeroUpgrade] { HeroUpgrade.mageUpgrades }
    var priestUpgrade: [HeroUpgrade] { HeroUpgrade.priestUpgrades }
    var lancerUpgrade: [HeroUpgrade] { HeroUpgrade.lancerUpgrades }

    func getRandom(
        for heroes: [UnitRole],
        upgraded: Bool,
        mageType: MageType?,
        consumedSpecialIDs: Set<String> = [],
        heroRoster: [HeroUnitModel] = [],
        draftMode: PerkDraftMode = .standard
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
        if roles.contains(.priest) {
            allAvailable.append(contentsOf: priestUpgrade)
        }
        if roles.contains(.lancer) {
            allAvailable.append(contentsOf: lancerUpgrade)
        }

        let basePool = allAvailable.filter { card in
            let notConsumed = !(card.rarity == .special && consumedSpecialIDs.contains(card.upgradeID))
            let scalerOK = !card.isRareMechanicScaler
                || mechanicScalerAllowed(card, roster: heroRoster, mageType: mageType)
            return notConsumed && scalerOK
        }

        switch draftMode {
        case .standard:
            return buildStandardDraft(from: basePool, total: total)
        case .specialOnly:
            return buildSpecialOnlyDraft(from: basePool, total: total)
        case .mixedRareSpecial(let specialChance):
            return buildMixedDraft(from: basePool, total: total, specialChance: specialChance)
        }
    }

    // MARK: - Draft builders

    private func buildStandardDraft(from basePool: [HeroUpgrade], total: Int) -> [HeroUpgrade] {
        let pool = basePool.filter { $0.rarity == .basic || $0.rarity == .rare }
        guard !pool.isEmpty else { return [] }

        var remaining = pool.shuffled()
        var result: [HeroUpgrade] = []

        if let basic = remaining.first(where: { $0.rarity == .basic }) {
            result.append(basic)
            remaining.removeAll { $0.upgradeID == basic.upgradeID }
        } else if let any = remaining.first {
            result.append(any)
            remaining.removeAll { $0.upgradeID == any.upgradeID }
        }

        while result.count < total, !remaining.isEmpty {
            let basics = remaining.filter { $0.rarity == .basic }
            let rares = remaining.filter { $0.rarity == .rare }
            let preferRare = Double.random(in: 0...1) < 0.20
            let pick = preferRare ? (rares.randomElement() ?? basics.randomElement()) : (basics.randomElement() ?? rares.randomElement())
            guard let chosen = pick else { break }
            result.append(chosen)
            remaining.removeAll { $0.upgradeID == chosen.upgradeID }
        }
        return result
    }

    private func buildSpecialOnlyDraft(from basePool: [HeroUpgrade], total: Int) -> [HeroUpgrade] {
        let pool = basePool.filter { $0.rarity == .special }
        if pool.isEmpty {
            let rarePool = basePool.filter { $0.rarity == .rare }
            if !rarePool.isEmpty {
                return pickUniqueRandom(count: total, from: rarePool)
            }
            return buildStandardDraft(from: basePool, total: total)
        }
        return pickUniqueRandom(count: total, from: pool)
    }

    private func buildMixedDraft(from basePool: [HeroUpgrade], total: Int, specialChance: Double) -> [HeroUpgrade] {
        let p = min(1, max(0, specialChance))
        let pool = basePool.filter { $0.rarity == .rare || $0.rarity == .special }
        if pool.isEmpty {
            return buildStandardDraft(from: basePool, total: total)
        }

        var remaining = pool.shuffled()
        var result: [HeroUpgrade] = []

        while result.count < total, !remaining.isEmpty {
            let specials = remaining.filter { $0.rarity == .special }
            let rares = remaining.filter { $0.rarity == .rare }
            let wantSpecial = !specials.isEmpty && Double.random(in: 0...1) < p
            let pick: HeroUpgrade?
            if wantSpecial {
                pick = specials.randomElement()
            } else {
                pick = rares.randomElement() ?? specials.randomElement()
            }
            guard let chosen = pick else { break }
            result.append(chosen)
            remaining.removeAll { $0.upgradeID == chosen.upgradeID }
        }

        while result.count < total, !remaining.isEmpty {
            let pick = remaining.randomElement()!
            result.append(pick)
            remaining.removeAll { $0.upgradeID == pick.upgradeID }
        }

        return result
    }

    private func pickUniqueRandom(count: Int, from pool: [HeroUpgrade]) -> [HeroUpgrade] {
        var remaining = pool.shuffled()
        var result: [HeroUpgrade] = []
        while result.count < count, !remaining.isEmpty {
            let pick = remaining.randomElement()!
            result.append(pick)
            remaining.removeAll { $0.upgradeID == pick.upgradeID }
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
