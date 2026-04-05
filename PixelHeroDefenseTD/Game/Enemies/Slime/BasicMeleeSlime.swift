//
//  BasicMeleeSlime.swift
//  PixelHeroDefenseTD
//

import SpriteKit

final class BasicMeleeSlime: BaseEnemyNode {
    init(model: EnemyUnitModel) {
        super.init(
            model: model,
            walk: SpriteSheet.horizontalStripTextures(imageNamed: "SlimeWalk", frameCount: 6),
            attack: SpriteSheet.horizontalStripTextures(imageNamed: "SlimeAttack", frameCount: 6),
            death: SpriteSheet.horizontalStripTextures(imageNamed: "SlimeDeath", frameCount: 4)
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not used")
    }
}
