//
//  UpgradeManager.swift
//  PixelHeroDefenseTD
//
//  Created by user on 25.03.2026.
//

import Foundation

class UpgradeManager {
    static let shared = UpgradeManager()

    private init() {}

    let archerUpgrade = HeroUpgrade.archerUpgrades
    let knightUpgrade = HeroUpgrade.knightUpgrades
  let mageUpgrade = HeroUpgrade.mageUpgrades

    /// `heroes` — ролі в команді. Декілька ролей → пул карток з усіх відповідних списків (перемішано).
    /// Один елемент — тільки перки цієї ролі (наприклад після підвищення рівня одного героя).
  func getRandom(for heroes: [UnitRole], upgraded: Bool, mageType: MageType?) -> [HeroUpgrade] {
        let amount = upgraded ? 4 : 3
        var allAvailable: [HeroUpgrade] = []
        let roles = Set(heroes)

        if roles.contains(.knight) {
            allAvailable.append(contentsOf: knightUpgrade)
        }
        if roles.contains(.archer) {
            allAvailable.append(contentsOf: archerUpgrade)
        }
		if roles.contains(.mage){
		  if let mageType{
			 allAvailable.append(contentsOf: mageUpgrade + [mageType.upgrade])
		  }else{
			 allAvailable.append(contentsOf: mageUpgrade + [HeroUpgrade.fireMage, HeroUpgrade.frostMage, HeroUpgrade.lightningMage])
		  }
		}

        guard !allAvailable.isEmpty else { return [] }

        return Array(allAvailable.shuffled().prefix(amount))
    }
}
