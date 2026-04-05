//
//  EnemyStatScaling.swift
//  PixelHeroDefenseTD
//

import Foundation

enum EnemyStatScaling {
    static func stats(for role: EnemyType, wave: Int) -> BasicEnemyStats {
        if let bk = role.bossKind {
            return BossStatScaling.enemyStats(for: bk, wave: wave)
        }
		let base: BasicEnemyStats = role.stats
        let hpMult = GameBalanceConfig.enemyHPMultiplier(forWave: wave)
        let dmgBonus = GameBalanceConfig.enemyDamageBonus(forWave: wave)
        let moveBonus = GameBalanceConfig.enemyMoveSpeedBonus(forWave: wave)
		  
        return BasicEnemyStats(
            baseDamage: base.baseDamage + dmgBonus,
            baseHP: base.baseHP * hpMult,
            attackSpeed: base.attackSpeed,
            moveSpeed: base.moveSpeed + moveBonus,
            range: base.range,
            reward: base.reward
        )
    }
}
