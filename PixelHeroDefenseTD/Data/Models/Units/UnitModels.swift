//
//  UnitModels.swift
//  PixelHeroDefenseTD
//

import Foundation

enum UnitRole: String, Sendable, CaseIterable {
  case knight
  case archer
  case mage
  case priest
  case lancer
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

  // MARK: Priest
  /// Лікування союзника в радіусі (HP/с). 0 — механіка вимкнена.
  var priestHealPerSecond: Double = 0
  /// Святі землі: сила уповільнення ворогів у радіусі (0…~0.85).
  var priestHolyGroundSlow: Double = 0
  /// Святий щит для переднього ряду: частка max HP союзника за хвилю (0.25…0.45). 0 — вимкнено.
  var priestHolyShieldPercent: Double = 0

  // MARK: Lancer (Lancelot)
  /// Якщо > 0 — кожен удар копʼя рахується як крит: множник `1 + bonus` (базово 0.5 = +50% шкоди).
  var lancerCritDamageBonus: Double = 0
  /// Стальові копита: глобальне уповільнення всіх ворогів (на кадр підтримується в `GameScene`).
  var lancerGlobalSlowPercent: Double = 0
  
  static func knightPrototype() -> HeroCombatStats {
	 HeroCombatStats(
		baseDamage: 12,
		baseHP: 100,
		attackSpeed: 1.0,
		range: 40,
		currentLevel: 1,
		enemyTarget: 1
	 )
  }
  static func archerPrototype() -> HeroCombatStats {
	 HeroCombatStats(
		baseDamage: 12,
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
  
  static func priestPrototype() -> HeroCombatStats {
    HeroCombatStats(
      baseDamage: 8,
      baseHP: 100,
      attackSpeed: 0.5,
      range: 55,
      currentLevel: 1,
      enemyTarget: 99
    )
  }
  
  static func lancerPrototype() -> HeroCombatStats{
	 HeroCombatStats(
		baseDamage: 20,
		baseHP: 150,
		attackSpeed: 1.4,
		range: 70,
		currentLevel: 1,
		enemyTarget: 1
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
	 case .priest:
		"PriestIcon"
	 case .lancer:
		"LancerIcon"
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
	 case .priest:
		"PriestHelmet"
	 case .lancer:
		"LancerHelmet"
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
	 case .priest:
		  .priestPrototype()
	 case .lancer:
		  .lancerPrototype()
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
