//
//  UnitModels.swift
//  PixelHeroDefenseTD
//

import Foundation

enum UnitRole: String, Sendable {
  case knight
  case archer
  case mage
}

enum MageType: String, Sendable{
  case lightning
  case fire
  case frost
}

struct HeroCombatStats: Sendable {
  var baseDamage: Double
  var baseHP: Double
  var attackSpeed: Double
  var range: Double
  var currentLevel: Int
  var enemyTarget: Int
  
  // For Upgrades
  var knockback: Double = 0
  var bounceCount: Int = 0           // Chain Shot
  var splashRadius: Double = 0
  var thornsPercentage: Double = 0.0   // Thorns (віддача шкоди)
  var damageReduction: Double = 0.0    // Plate (зменшення шкоди)
  var slownessEffect: Double = 0.0     // Poison Tipped (заповільнення)
  var focusDistanceBonus: Double = 0.0 // Focus Shot damage scale for long distance enemy
  var lifestealPercentage: Double = 0.0 // Vampirism from artifact
  var critChance: Double = 0.0         // Encyclopedia from artifact
  var isEnragedActive: Double = 0.0    // Enraged механіка % hp коли втупає
  /// Множник швидкості атаки під час люті (коли `isEnragedActive > 0` і HP нижче порогу).
  var enrageAttackSpeedMultiplier: Double = 1.5
  var upgradeStacks: [String: Int] = [:]
  /// Механіки, розблоковані **special** картками (для rare «+10% до механіки»).
  var unlockedMechanics: Set<MechanicFamily> = []
  var mageType: MageType? = nil
  
  static func knightPrototype() -> HeroCombatStats {
	 HeroCombatStats(
		baseDamage: 12,
		baseHP: 100,
		attackSpeed: 1.0,
		range: 45,
		currentLevel: 1,
		enemyTarget: 2
	 )
  }
  static func archerPrototype() -> HeroCombatStats {
	 HeroCombatStats(
		baseDamage: 10,
		baseHP: 100,
		attackSpeed: 1.2,
		range: 110,
		currentLevel: 1,
		enemyTarget: 1
	 )
  }
  static func magePrototype() -> HeroCombatStats {
	 HeroCombatStats(
		baseDamage: 15,
		baseHP: 100,
		attackSpeed: 1.2,
		range: 90,
		currentLevel: 1,
		enemyTarget: 1,
		bounceCount: 2
	 )
  }
}

struct HeroUnitModel: Identifiable, Sendable {
  let id: UUID
  var role: UnitRole
  var stats: HeroCombatStats
  
  init(id: UUID = UUID(), role: UnitRole, stats: HeroCombatStats) {
	 self.id = id
	 self.role = role
	 self.stats = stats
  }
}


extension UnitRole{
  var upgradeIcon: String{
	 switch self {
	 case .knight:
		"KnightIcon"
	 case .archer:
		"ArcherIcon"
	 case .mage:
		"MageIcon"
	 }
  }
  
  var helmetIcon: String{
	 switch self {
	 case .knight:
		"KnightHelmet"
	 case .archer:
		"ArcherHelmet"
	 case .mage:
		"MageHelmet"
	 }
  }
  
  var stats: HeroCombatStats{
	 switch self {
	 case .knight:
		  .knightPrototype()
	 case .archer:
		  .archerPrototype()
	 case .mage:
		  .magePrototype()
	 }
  }
}


extension MageType {
    /// Додаткові картки шляху мага в пулі (повторні path-special прибираються через `consumedSpecialIDs`).
    var pathExtraUpgrades: [HeroUpgrade] {
        switch self {
        case .lightning:
            [HeroUpgrade.lightningMage]
        case .fire:
            [HeroUpgrade.fireMage]
        case .frost:
            [HeroUpgrade.frostMage]
        }
    }
}
