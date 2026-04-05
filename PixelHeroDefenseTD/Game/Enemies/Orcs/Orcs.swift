//
//  BasicMeleeOrc.swift
//  PixelHeroDefenseTD
//

import SpriteKit

final class BasicMeleeOrc: BaseEnemyNode {
    init(model: EnemyUnitModel) {
        super.init(
            model: model,
            walk: SpriteSheet.horizontalStripTextures(imageNamed: "OrcWalk", frameCount: 8),
            attack: SpriteSheet.horizontalStripTextures(imageNamed: "OrcAttack", frameCount: 6),
            death: SpriteSheet.horizontalStripTextures(imageNamed: "OrcDeath", frameCount: 4)
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not used")
    }
}
final class ArmoredMeleeOrc: BaseEnemyNode {
    init(model: EnemyUnitModel) {
        super.init(
            model: model,
            walk: SpriteSheet.horizontalStripTextures(imageNamed: "ArmoredOrcWalk", frameCount: 8),
            attack: SpriteSheet.horizontalStripTextures(imageNamed: "ArmoredOrcAttack", frameCount: 7),
            death: SpriteSheet.horizontalStripTextures(imageNamed: "ArmoredOrcDeath", frameCount: 4)
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not used")
    }
}
