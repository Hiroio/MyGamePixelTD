//
//  WereWolf.swift
//  PixelHeroDefenseTD
//
//  Created by user on 26.03.2026.
//

import SpriteKit

final class WereWolf: BaseEnemyNode {
	 init(model: EnemyUnitModel) {
		  super.init(
				model: model,
				walk: SpriteSheet.horizontalStripTextures(imageNamed: "WerewolfWalk", frameCount: 8),
				attack: SpriteSheet.horizontalStripTextures(imageNamed: "WerewolfAttack", frameCount: 9),
				death: SpriteSheet.horizontalStripTextures(imageNamed: "WerewolfDeath", frameCount: 4)
		  )
	 }

	 required init?(coder aDecoder: NSCoder) {
		  fatalError("init(coder:) not used")
	 }
}
