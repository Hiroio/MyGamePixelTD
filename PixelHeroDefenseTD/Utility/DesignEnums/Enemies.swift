//
//  Enemies.swift
//  PixelHeroDefenseTD
//
//  Created by user on 10.04.2026.
//

import Foundation
import SwiftUI

extension EnemyType{
  var iconAnimation: [UIImage]{
	 switch self {
	 case .slime:
		return UIImage.cropSprite(name: "SlimeIdle", count: 6)
	 case .orc:
		return UIImage.cropSprite(name: "OrcIdle", count: 6)
	 case .skeleton:
		return UIImage.cropSprite(name: "SkeletonIdle", count: 6)
	 case .armoredSkeleton:
		return UIImage.cropSprite(name: "ArmoredSkeletonIdle", count: 6)
	 case .armoredOrc:
		return UIImage.cropSprite(name: "ArmoredOrcIdle", count: 6)
	 case .swordsmanSkeleton:
		return UIImage.cropSprite(name: "SwordsmanSkeletonIdle", count: 6)
	 case .werewolf:
		return UIImage.cropSprite(name: "WerewolfIdle", count: 6)
	 case .werebear:
		return UIImage.cropSprite(name: "WerebearIdle", count: 6)
	 case .eliteOrcBoss:
		return UIImage.cropSprite(name: "EliteOrcIdle", count: 6)
	 case .kingSlimeBoss:
		return UIImage.cropSprite(name: "SlimeIdle", count: 6)
	 case .armoredSkeletonBoss:
		return UIImage.cropSprite(name: "ArmoredSkeletonIdle", count: 6)
	 case .void:
		return UIImage.cropSprite(name: "EliteOrcIdle", count: 6)
	 }
  }
}
