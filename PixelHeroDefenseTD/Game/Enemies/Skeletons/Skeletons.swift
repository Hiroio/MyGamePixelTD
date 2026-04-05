//
//  BasicSkeleton.swift
//  PixelHeroDefenseTD
//
//  Created by user on 26.03.2026.
//

import SpriteKit

final class BasicSkeleton: BaseEnemyNode {
	 init(model: EnemyUnitModel) {
		  super.init(
				model: model,
				walk: SpriteSheet.horizontalStripTextures(imageNamed: "SkeletonWalk", frameCount: 8),
				attack: SpriteSheet.horizontalStripTextures(imageNamed: "SkeletonAttack", frameCount: 6),
				death: SpriteSheet.horizontalStripTextures(imageNamed: "SkeletonDeath", frameCount: 4)
		  )
	 }

	 required init?(coder aDecoder: NSCoder) {
		  fatalError("init(coder:) not used")
	 }
}
final class ArmoredSkeleton: BaseEnemyNode {
	 init(model: EnemyUnitModel) {
		  super.init(
				model: model,
				walk: SpriteSheet.horizontalStripTextures(imageNamed: "ArmoredSkeletonWalk", frameCount: 8),
				attack: SpriteSheet.horizontalStripTextures(imageNamed: "ArmoredSkeletonAttack01", frameCount: 8),
				death: SpriteSheet.horizontalStripTextures(imageNamed: "ArmoredSkeletonDeath", frameCount: 4)
		  )
	 }

	 required init?(coder aDecoder: NSCoder) {
		  fatalError("init(coder:) not used")
	 }
}
final class SwordsmanSkeleton: BaseEnemyNode {
	 init(model: EnemyUnitModel) {
		  super.init(
				model: model,
				walk: SpriteSheet.horizontalStripTextures(imageNamed: "SwordsmanSkeletonWalk", frameCount: 9),
				attack: SpriteSheet.horizontalStripTextures(imageNamed: "SwordsmanSkeletonAttack", frameCount: 9),
				death: SpriteSheet.horizontalStripTextures(imageNamed: "SwordsmanSkeletonDeath", frameCount: 4)
		  )
	 }

	 required init?(coder aDecoder: NSCoder) {
		  fatalError("init(coder:) not used")
	 }
}
