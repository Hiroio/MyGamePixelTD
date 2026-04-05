//
//  BossModel.swift
//  PixelHeroDefenseTD
//

import Foundation

/// Типи босів (по колу кожні 10 хвиль).
enum BossKind: Int, CaseIterable, Sendable {
  case kingSlime
  case eliteOrc
  case armoredSkeleton
  
  var name: String{
	 switch self {
	 case .kingSlime:
		"King Slime"
	 case .eliteOrc:
		"Elite Orc"
	 case .armoredSkeleton:
		"Armored Skeleton"
	 }
  }
  
  static func forWaveNumber(_ wave: Int) -> BossKind? {
	 guard wave > 0, wave % 10 == 0 else { return nil }
	 let idx = (wave / 10 - 1) % BossKind.allCases.count
	 return BossKind(rawValue: idx)
  }
  
  var enemyType: EnemyType {
	 switch self {
	 case .eliteOrc: .eliteOrcBoss
	 case .kingSlime: .kingSlimeBoss
	 case .armoredSkeleton: .armoredSkeletonBoss
	 }
  }
  
  var bossUnitModel: BossUnitModel {
	 switch self {
	 case .eliteOrc:
		BossUnitModel(
		  kind: self,
		  isRanged: false,
		  delaySeconds: 2.0,
		  baseHP: 2000,
		  baseDamage: 80,
		  attackRange: 5,
		  reward: 75,
		  round: 20
		)
	 case .kingSlime:
		BossUnitModel(
		  kind: self,
		  isRanged: false,
		  delaySeconds: 2.4,
		  baseHP: 1000,
		  baseDamage: 55,
		  attackRange: 5,
		  reward: 75,
		  round: 10
		)
	 case .armoredSkeleton:
		BossUnitModel(
		  kind: self,
		  isRanged: false,
		  delaySeconds: 1.75,
		  baseHP: 2500,
		  baseDamage: 70,
		  attackRange: 5,
		  reward: 80,
		  round: 30
		)
	 }
  }
}

struct BossUnitModel: Sendable {
  let kind: BossKind
  let isRanged: Bool
  let delaySeconds: Double
  let baseHP: Double
  let baseDamage: Double
  let attackRange: Double
  let reward: Int
  let round: Int
}

enum BossStatScaling {
  static func enemyStats(for kind: BossKind, wave: Int) -> BasicEnemyStats {
	 let b = kind.bossUnitModel
	 let hpMult = GameBalanceConfig.enemyHPMultiplier(forWave: wave)
	 let dmgBonus = GameBalanceConfig.enemyDamageBonus(forWave: wave)
	 let moveBonus = GameBalanceConfig.enemyMoveSpeedBonus(forWave: wave)
	 let tier = max(0, wave / 10)
	 let bossHPMult = 1.0 + 0.15 * Double(tier)
	 let bossDmgMult = 1.0 + 0.08 * Double(tier)
	 let asp: Double
	 switch kind {
	 case .eliteOrc: asp = 0.48
	 case .kingSlime: asp = 0.52
	 case .armoredSkeleton: asp = 0.62
	 }
	 return BasicEnemyStats(
		baseDamage: (b.baseDamage * bossDmgMult) + dmgBonus,
		baseHP: (b.baseHP * bossHPMult) * hpMult,
		attackSpeed: asp,
		moveSpeed: 0.95 + moveBonus,
		range: b.attackRange,
		reward: b.reward
	 )
  }
}
