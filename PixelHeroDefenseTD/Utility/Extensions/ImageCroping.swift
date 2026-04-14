//
//  ImageCroping.swift
//  PixelHeroDefenseTD
//
//  Created by user on 11.04.2026.
//

import Foundation
import UIKit

extension UIImage{
  static func cropSprite(
	 name: String,
	 count: Int,
  ) -> [UIImage]{
	 let image = UIImage(named: name)
	 var images: [UIImage] = []
	 for i in 0..<count{
		if let cropped = image?.cgImage?.cropping(to: CGRect(origin: CGPoint(x: i * 100, y: 0), size: CGSize(width: 100, height: 100))) {
		  images.append(UIImage(cgImage: cropped))
		}
	 }
	 return images
  }
}
