//
//  SpriteSheet.swift
//  PixelHeroDefenseTD
//

import SpriteKit
import UIKit

enum SpriteSheet {
    static func horizontalStripTextures(
        imageNamed: String,
        frameCount: Int,
        filteringMode: SKTextureFilteringMode = .nearest
    ) -> [SKTexture] {
        guard frameCount > 0, let image = UIImage(named: imageNamed) else { return [] }

        let fullW = image.size.width
        let fullH = image.size.height
        guard fullW > 0, fullH > 0 else { return [] }

        let frameW = fullW / CGFloat(frameCount)
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        format.scale = image.scale

        var frames: [SKTexture] = []
        for i in 0..<frameCount {
            let outSize = CGSize(width: frameW, height: fullH)
            let renderer = UIGraphicsImageRenderer(size: outSize, format: format)
            let frameImage = renderer.image { _ in
                image.draw(in: CGRect(x: -CGFloat(i) * frameW, y: 0, width: fullW, height: fullH))
            }
            let t = SKTexture(image: frameImage)
            t.filteringMode = filteringMode
            frames.append(t)
        }
        return frames
    }

    /// Окремі imageset-и з іменами `BaseName1` … `BaseNameN` (як у FinaleBoss).
    static func sequentialNamedTextures(
        baseName: String,
        startIndex: Int = 1,
        endIndex: Int,
        filteringMode: SKTextureFilteringMode = .nearest
    ) -> [SKTexture] {
        guard endIndex >= startIndex else { return [] }
        var frames: [SKTexture] = []
        for i in startIndex...endIndex {
            let texture = SKTexture(imageNamed: "\(baseName)\(i)")
            if texture.size().width > 0.5 {
                texture.filteringMode = filteringMode
                frames.append(texture)
            }
        }
        return frames
    }
}
