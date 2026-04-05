//
//  UpgradeData.swift
//  PixelHeroDefenseTD
//
//  Created by user on 25.03.2026.
//

import Foundation

extension HeroUpgrade {
    static let knightUpgrades: [HeroUpgrade] = [
        HeroUpgrade(name: "Berserker", description: "Atk Speed +20%, Dmg +5%", icon: "Berserk", targetRole: .knight, stepDescription: "Next stack: Atk Speed +20%, Dmg +5%", apply: {
            $0.attackSpeed *= 1.2
            $0.baseDamage *= 1.05
        }, step: {
            $0.attackSpeed *= 1.2
            $0.baseDamage *= 1.05
        }),
        HeroUpgrade(name: "Cleave", description: "1 target + splash AoE. Radius 10, +5%/stack", icon: "Cleve", targetRole: .knight, stepDescription: "Next stack: splash radius +5%", apply: {
            $0.enemyTarget = 1
            $0.splashRadius = 10
			 $0.baseDamage *= 0.7
        }, step: {
            $0.splashRadius *= 1.05
        }),
        HeroUpgrade(name: "Bouler", description: "Knockback +1.0", icon: "Bouler", targetRole: .knight, stepDescription: "Next stack: Knockback +1.0", apply: {
            $0.knockback += 1.0
        }, step: {
            $0.knockback += 1.0
        }),
        HeroUpgrade(name: "Thorns", description: "Return 10% damage back", icon: "Thorns", targetRole: .knight, stepDescription: "Next stack: return +10% damage", apply: {
            $0.thornsPercentage += 0.1
        }, step: {
            $0.thornsPercentage += 0.1
        }),
        HeroUpgrade(name: "Heavy Armor", description: "-20% Dmg taken,\n-10% Atk Speed", icon: "HeavyArmor", targetRole: .knight, stepDescription: "Next stack: -20% damage taken, -10% attack speed", apply: {
            $0.damageReduction += 0.2
            $0.attackSpeed *= 0.9
        }, step: {
            $0.damageReduction += 0.2
            $0.attackSpeed *= 0.9
        }),
        HeroUpgrade(name: "Enraged", description: "Below 30% HP: +50% Atk Speed", icon: "Enrage", targetRole: .knight, stepDescription: "Already active: no extra stack effect", apply: {
            $0.isEnragedActive = 0.3
        }, step: { _ in })
    ]

    // MARK: - ARCHER UPGRADES

    static let archerUpgrades: [HeroUpgrade] = [
        HeroUpgrade(name: "Heavy Arrows", description: "Knockback +1.0, Damage +10%", icon: "HeavyArrows", targetRole: .archer, stepDescription: "Next stack: Knockback +0.5", apply: {
            $0.knockback += 1.0
            $0.baseDamage *= 1.10
        }, step: {
            $0.knockback += 0.5
        }),
        HeroUpgrade(name: "Chain Shot", description: "Bounce to 2 extra targets, bounce dmg 50%", icon: "ChainShot", targetRole: .archer, stepDescription: "Next stack: +1 bounce target", apply: {
            $0.bounceCount += 2
			 $0.baseDamage *= 0.3
        }, step: {
            $0.bounceCount += 1
        }),
        HeroUpgrade(name: "Long Bow", description: "Range +20", icon: "LongBow", targetRole: .archer, stepDescription: "Next stack: Range +10", apply: {
            $0.range += 20
        }, step: {
            $0.range += 10
        }),
        HeroUpgrade(name: "Freeing Bow", description: "Shot enemies: -20% speed for 2s", icon: "FreezingBow", targetRole: .archer, stepDescription: "Next stack: +10% slow", apply: {
            $0.slownessEffect += 0.2
        }, step: {
            $0.slownessEffect += 0.1
        }),
        HeroUpgrade(name: "Focus Shot", description: "If target distance > 50: +20% dmg", icon: "FocusShot", targetRole: .archer, stepDescription: "Next stack: +10% focus damage", apply: {
            $0.focusDistanceBonus += 0.2
        }, step: {
            $0.focusDistanceBonus += 0.1
        }),
        HeroUpgrade(name: "Multi Shot", description: "+1 targets, -10% dmg", icon: "MultiShot", targetRole: .archer, stepDescription: "Next stack: +1 target", apply: {
            $0.enemyTarget += 1
			 $0.baseDamage *= 0.9
        }, step: {
            $0.enemyTarget += 1
        })
		  ]
  
  
  static let mageUpgrades: [HeroUpgrade] = [
//		  MARK: MAGE UPGRADES
		  
		  HeroUpgrade(name: "Sourcer Staff", description: "Icrease Attack Sp, Damage for 10%", icon: "Staff", targetRole: .mage, stepDescription: "Icrease Attack Sp, Damage for 10%", apply: {
			 $0.baseDamage *= 1.1
			 $0.attackSpeed *= 1.1
		  }, step: {
			 $0.attackSpeed *= 1.1
			 $0.baseDamage *= 1.1
		  }),
		  
		  HeroUpgrade(name: "Third eye", description: "+1 enemy Target, -10% damage", icon: "ThirdEye", targetRole: .mage, stepDescription: "+1 enemy Target, -10% damage", apply: {
			 $0.enemyTarget += 1
			 $0.baseDamage *= 0.9
		  }, step: {
			 $0.enemyTarget += 1
			 $0.baseDamage *= 0.9
		  })
    ]
  
  
  static let lightningMage: HeroUpgrade = HeroUpgrade(name: "Lightning Mage", description: "Improove lightning skills. + 1 bounce, + 1 knockback, 10% damage", icon: "LightningMage", targetRole: .mage, stepDescription: "Improove skills, 1-extra Bounce, +0.5 Knockback, 10% Damage", apply: {
	 $0.knockback = 1.0
		  $0.baseDamage *= 1.1
		  $0.bounceCount += 1
		}, step: {
		  $0.knockback += 0.5
		  $0.baseDamage *= 1.1
		  $0.bounceCount += 1
		})
  
  static let fireMage: HeroUpgrade = HeroUpgrade(name: "Fire Mage", description: "Change attack for AOE Fireball", icon: "FireMage", targetRole: .mage, stepDescription: "Base Damage 10% increase. AOE 10% Increase", apply: {
	 $0.mageType = .fire
		  $0.attackSpeed *= 0.9
		  $0.baseDamage *= 1.1
		  $0.splashRadius = 15
		}, step: {
		  $0.baseDamage *= 1.1
		  $0.splashRadius *= 1.1
		})
  
  static let frostMage: HeroUpgrade = HeroUpgrade(name: "Frost Mage", description: "Change attack for Frost Shards(AOE Attack with slowness effect)", icon: "FrostMage", targetRole: .mage, stepDescription: "Slowness Effect increase 10%, Radius increased 10%", apply: {
	 $0.mageType = .frost
		  $0.attackSpeed *= 0.9
		  $0.splashRadius = 20
		  $0.slownessEffect = 0.5
		}, step:{
		  $0.splashRadius *= 1.1
		  $0.slownessEffect *= 1.1
		})
}
