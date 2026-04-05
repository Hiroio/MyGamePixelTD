//
//  BossHUD.swift
//  PixelHeroDefenseTD
//
//  Created by user on 31.03.2026.
//

import SwiftUI

struct BossHUD: View {
  let totalHP: Double
  let currentHP: Double
  let bossName: BossKind
    var body: some View {
		VStack(alignment: .center, spacing: 30){
		  Text(bossName.name)
			 .font(.custom("Antiquity Print", size: 24))
			 .foregroundStyle(.red.mix(with: .black, by: 0.2))
			 .shadow(radius: 1, x: 1, y: 3)
		  GeometryReader{geo in
			 ZStack(alignment: .leading){
				RoundedRectangle(cornerRadius: 10)
				  .frame(width: geo.size.width * (currentHP / totalHP))
			 }
		  }
		  .padding(.horizontal)
		  .frame(height: 35)
		  .overlay(
			 Image("Border")
				.resizable()
				.scaledToFill()
		  )
		  .padding(.horizontal)
		}
		.foregroundStyle(.red.mix(with: .black, by: 0.1))
		.padding(.horizontal)
    }
}

#Preview {
  BossHUD(totalHP: 1000, currentHP: 1000, bossName: .armoredSkeleton)
}
