//
//  BattlefieldBackgroundNode.swift
//  PixelHeroDefenseTD
//

import SpriteKit
import UIKit

/// Тайловий фон (трава); перебудовується при зміні `scene.size`.
final class BattlefieldBackgroundNode: SKNode {
    func rebuild(in sceneSize: CGSize, grassImageName: String = "grass1") {
        removeAllChildren()

        guard let image = UIImage(named: grassImageName),
        let image2 = UIImage(named: "grass2"),
		  let image3 = UIImage(named: "grass3")
		else { return }
        let base = SKTexture(image: image)
        let base2 = SKTexture(image: image2)
        let base3 = SKTexture(image: image3)
        base.filteringMode = .nearest

        let tile = SceneLayout.grassTileWorldSize(for: sceneSize)
        let halfW = sceneSize.width * 0.5
        let halfH = sceneSize.height * 0.5

        let cols = Int(ceil(sceneSize.width / tile)) + 3
        let rows = Int(ceil(sceneSize.height / tile)) + 3

        let startX = -halfW - tile
        let startY = -halfH - tile

        for row in 0..<rows {
            for col in 0..<cols {
				  var s: SKSpriteNode
				  if Int.random(in: 1...8) == 5{
					 s = SKSpriteNode(texture: base2)
				  }else if Int.random(in: 1...8) == 4{
					 s = SKSpriteNode(texture: base3)
				  }else{
					 s = SKSpriteNode(texture: base)
				  }
                s.texture?.filteringMode = .nearest
                s.size = CGSize(width: tile, height: tile)
                s.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                s.position = CGPoint(
                    x: startX + CGFloat(col) * tile + tile * 0.5,
                    y: startY + CGFloat(row) * tile + tile * 0.5
                )
                s.zPosition = -200
                addChild(s)
            }
        }
    }
}
