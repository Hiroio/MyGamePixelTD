//
//  ArtifactModel.swift
//  PixelHeroDefenseTD
//
//  Created by user on 25.03.2026.
//

import Foundation


enum ArtifactID: String, CaseIterable, Sendable {
  case goldenBlacksmith // golden blacksmith - discount for upgrade
  case bonusMeal			 // Bonus meal buff stats
  case magicLamp       // mirror hope - 4 slot for options
  case luckyCoin       // lucky coin + 15% coin earn
  case barricades      // barricade
  case enemyEncyclopedia // crit chance
}

struct Artifact: Identifiable, Sendable {
  let id: ArtifactID
  let name: String
  let description: String
  let icon: String
  
  init(id: ArtifactID, name: String, description: String, icon: String){
	 self.id = id
	 self.name = name
	 self.description = description
	 self.icon = icon
  }
}


extension Artifact{
  static let allArtifact: [Artifact] = [
	 Artifact(id: .goldenBlacksmith ,name: "Golden Blacksmith", description: "Hero upgrades cost 20%", icon: "GoldenBlacksmith"),
	 Artifact(id: .bonusMeal ,name: "Bonus Meal", description: "Hero damage increase for 15%", icon: "BonusMeal"),
	 Artifact(id: .magicLamp ,name: "Magic Lamp", description: "Unlock 4th option for upgrades", icon: "MagicLamp"),
	 Artifact(id: .luckyCoin ,name: "Lucky Coin", description: "Enemy drop 10% more coins", icon: "Bank"),
	 Artifact(id: .barricades ,name: "Barricade", description: "Builds a barricade(200hp) in front of the heroes", icon: "Baricade"),
	 Artifact(id: .enemyEncyclopedia, name: "Monster Guide", description: "Crit Chance increase for 30%", icon: "Encyclopedia")
  ]
}
