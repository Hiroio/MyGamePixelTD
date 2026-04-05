//
//  WereBear.swift
//  PixelHeroDefenseTD
//
//  Created by user on 26.03.2026.
//

import SpriteKit

final class Werebear: BaseEnemyNode {
	 init(model: EnemyUnitModel) {
		  super.init(
				model: model,
				walk: SpriteSheet.horizontalStripTextures(imageNamed: "WerebearWalk", frameCount: 8),
				attack: SpriteSheet.horizontalStripTextures(imageNamed: "WerebearAttack", frameCount: 9),
				death: SpriteSheet.horizontalStripTextures(imageNamed: "WerebearDeath", frameCount: 4)
		  )
	 }

	 required init?(coder aDecoder: NSCoder) {
		  fatalError("init(coder:) not used")
	 }
}
