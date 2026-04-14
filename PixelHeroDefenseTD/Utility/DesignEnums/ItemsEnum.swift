//
//  ItemsEnum.swift
//  PixelHeroDefenseTD
//
//  Created by user on 13.04.2026.
//

import Foundation


extension ArtifactID{
  var text: String{
	 switch self {
	 case .goldenBlacksmith:
		"Golden Blacksmith"
	 case .bonusMeal:
		"Bonus Meal"
	 case .magicLamp:
		"Magic Lamp"
	 case .luckyCoin:
		"Lucky Coin"
	 case .barricades:
		"Barricades"
	 case .enemyEncyclopedia:
		"Monster Guide"
	 }
  }
  
  var icon: String{
	 switch self {
	 case .goldenBlacksmith:
		"GoldenBlacksmith"
	 case .bonusMeal:
		"BonusMeal"
	 case .magicLamp:
		"MagicLamp"
	 case .luckyCoin:
		"Bank"
	 case .barricades:
		"Baricade"
	 case .enemyEncyclopedia:
		"Encyclopedia"
	 }
  }
  
  var description: String{
	 switch self {
	 case .goldenBlacksmith:
		"Hero upgrades cost 20% less"
	 case .bonusMeal:
		"Heroes damage increase for 15%"
	 case .magicLamp:
		"Unlock 4th option for upgrades"
	 case .luckyCoin:
		"Enemy drop 10% more coins"
	 case .barricades:
		"Builds a barricade(200hp) in front of the heroes"
	 case .enemyEncyclopedia:
		"Crit Chance increase for 30%"
	 }
  }
}
