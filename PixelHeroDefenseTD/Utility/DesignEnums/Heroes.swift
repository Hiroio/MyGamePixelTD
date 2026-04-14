//
//  Heroes.swift
//  PixelHeroDefenseTD
//
//  Created by user on 10.04.2026.
//

import Foundation


extension UnitRole{
  
  var name: String{
	 switch self {
	 case .knight:
		"Rudolf"
	 case .archer:
		"Robin"
	 case .mage:
		"Catherine"
	 case .priest:
		"Elizabeth"
	 case .lancer:
		"Robert"
	 }
  }
  
  var bio: String{
	 switch self {
	 case .knight:
		"He swore to stand in the path of every wave—and he has not taken a step back since. Rudolf keeps talk short: there is a front line, and he holds it."
	 case .archer:
		"Robin grew up in the woods until the shadows between the trees looked like targets. He likes fights where the enemy never reaches the wall."
	 case .mage:
		"Catherine learned the grammar of lightning and flame from brittle old tomes, and now speaks it more clearly than most people. To her, chaos on the battlefield is just fuel for a spell."
	 case .priest:
		"Elizabeth carries light as more than a symbol—she learned to mend flesh where fire had already taken its share. Her prayers smell of ozone and a little ash."
	 case .lancer:
		"Robert rode in from the marches, where a lance ends an argument faster than a judge. He is used to charging through and not counting how many stand behind the first rank."
	 }
  }
  
  /// How the hero plays in combat (game mechanics).
  var description: String{
	 switch self {
	 case .knight:
		"Melee fighter: cuts enemies in the front row, can deal splash damage, knock foes back, and anchor the line. Works as a wall and a source of battlefield control."
	 case .archer:
		"Ranged DPS: shoots from a distance, can hit several enemies per volley, ricochet arrows, and apply slows. Strong for steady damage and cleaning up groups."
	 case .mage:
		"Magical attacks: choose lightning (chaining), fire (explosive AoE), or frost (slows and area damage). Excels against clumps and wave control."
	 case .priest:
		"Support and burn damage: sets enemies on fire, heals allies in range, can boost team survivability, slow foes around you, and grant front-row shields at the start of a wave."
	 case .lancer:
		"Thrown lance strikes: accurate ranged hits with options for a line charge, multiple targets per volley, ricochets, and a global enemy slow. Flexible damage and control at range."
	 }
  }
}
