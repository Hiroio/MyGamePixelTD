//
//  GameSceneManager.swift
//  PixelHeroDefenseTD
//
//  Created by user on 26.03.2026.
//

import Foundation


class GameSceneManager{
  static let shared = GameSceneManager()
  
  
  private init(){}
  
  func getEnemyTypes(for wave: Int) -> [EnemyType] {
		switch wave {
		case 0...3:   return [.slime]
		case 4...5:   return [.slime, .skeleton]
		case 6...8:   return [.skeleton, .orc]
		case 9...10:  return [.orc, .armoredOrc, .skeleton]
		case 11...12: return [.armoredSkeleton, .armoredOrc, .swordsmanSkeleton]
		case 15...20: return [.swordsmanSkeleton, .werebear, .werewolf]
		default:      return [.armoredOrc, .werewolf, .swordsmanSkeleton, .werebear]
		}
  }
}
