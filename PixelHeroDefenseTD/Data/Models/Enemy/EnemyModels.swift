//
//  EnemyModels.swift
//  PixelHeroDefenseTD
//
//  Created by user on 23.03.2026.
//

import Foundation


enum EnemyType: String, Sendable, Identifiable, CaseIterable {
  case slime
  case orc
  case skeleton
  case armoredSkeleton
  case armoredOrc
  case swordsmanSkeleton
  case werewolf
  case werebear
  /// Боси (окрема логіка AI та спавн на 5/10/15/20).
  case eliteOrcBoss
  case kingSlimeBoss
  case armoredSkeletonBoss
  case void
  
  var id: String{
	 self.rawValue
  }
}

struct BasicEnemyStats: Sendable {
  var baseDamage: Double
  var baseHP: Double
  var attackSpeed: Double
  var moveSpeed: Double
  var range: Double
  var reward: Int
  
  static func orc() -> BasicEnemyStats {
	 BasicEnemyStats(
		baseDamage: 2,
		baseHP: 15,
		attackSpeed: 1.0,
		moveSpeed: 0.70,
		range: 5,
		reward: 5
	 )
  }
  static func slime() -> BasicEnemyStats {
	 BasicEnemyStats(
		baseDamage: 1,
		baseHP: 9,
		attackSpeed: 1.0,
		moveSpeed: 1.05,
		range: 10,
		reward: 3
	 )
  }
  static func skeleton() -> BasicEnemyStats{
	 BasicEnemyStats(baseDamage: 2, baseHP: 12, attackSpeed: 1.1, moveSpeed: 0.97, range: 5, reward: 4)
  }
  static func armoredSkeleton() -> BasicEnemyStats{
	 BasicEnemyStats(baseDamage: 2, baseHP: 35, attackSpeed: 1.1, moveSpeed: 0.97, range: 5, reward: 8)
  }
  static func swordsmanSkeleton() -> BasicEnemyStats{
	 BasicEnemyStats(baseDamage: 4, baseHP: 50, attackSpeed: 1.1, moveSpeed: 0.97, range: 5, reward: 8)
  }
  static func armoredOrc() -> BasicEnemyStats{
	 BasicEnemyStats(baseDamage: 2, baseHP: 40, attackSpeed: 1.0, moveSpeed: 0.88, range: 5, reward: 10)
  }
  static func werewolf() -> BasicEnemyStats{
	 BasicEnemyStats(baseDamage: 3, baseHP: 65, attackSpeed: 1.2, moveSpeed: 1.06, range: 5, reward: 7)
  }
  static func werebear() -> BasicEnemyStats{
	 BasicEnemyStats(baseDamage: 4, baseHP: 75, attackSpeed: 1.2, moveSpeed: 1.06, range: 5, reward: 8)
  }
}

struct EnemyUnitModel: Identifiable, Sendable {
  let id: UUID
  var role: EnemyType
  var stats: BasicEnemyStats
  
  init(id: UUID = UUID(), role: EnemyType, stats: BasicEnemyStats) {
	 self.id = id
	 self.role = role
	 self.stats = stats
  }
}


extension EnemyType{
  func createNode(model: EnemyUnitModel) -> BaseEnemyNode{
	 switch self {
	 case .slime:
		BasicMeleeSlime(model: model)
	 case .orc:
		BasicMeleeOrc(model: model)
	 case .skeleton:
		BasicSkeleton(model: model)
	 case .armoredSkeleton:
		ArmoredSkeleton(model: model)
	 case .armoredOrc:
		ArmoredMeleeOrc(model: model)
	 case .werewolf:
		WereWolf(model: model)
	 case .swordsmanSkeleton:
		SwordsmanSkeleton(model: model)
	 case .werebear:
		Werebear(model: model)
	 case .eliteOrcBoss:
		BossKind.eliteOrc.makeMeleeBoss(model: model)
	 case .kingSlimeBoss:
		BossKind.kingSlime.makeMeleeBoss(model: model)
	 case .armoredSkeletonBoss:
		BossKind.armoredSkeleton.makeMeleeBoss(model: model)
	 case .void:
		FinaleBossNode(model: model)
	 }
  }

  /// Для `EnemyStatScaling`: боси мапляться на `BossKind`.
  var bossKind: BossKind? {
    switch self {
    case .eliteOrcBoss: .eliteOrc
    case .kingSlimeBoss: .kingSlime
    case .armoredSkeletonBoss: .armoredSkeleton
    case .void: .void
    default: nil
    }
  }
  
  var stats: BasicEnemyStats{
	 switch self {
	 case .slime:
		  .slime()
	 case .orc:
		  .orc()
	 case .skeleton:
		  .skeleton()
	 case .armoredSkeleton:
		  .armoredSkeleton()
	 case .armoredOrc:
		  .armoredOrc()
	 case .swordsmanSkeleton:
		  .swordsmanSkeleton()
	 case .werewolf:
		  .werewolf()
	 case .werebear:
		  .werebear()
	 case .eliteOrcBoss:
		BossStatScaling.enemyStats(for: .eliteOrc, wave: 1)
	 case .kingSlimeBoss:
		BossStatScaling.enemyStats(for: .kingSlime, wave: 1)
	 case .armoredSkeletonBoss:
		BossStatScaling.enemyStats(for: .armoredSkeleton, wave: 1)
	 case .void:
		BossStatScaling.enemyStats(for: .void, wave: 1)
	 }
  }
}
