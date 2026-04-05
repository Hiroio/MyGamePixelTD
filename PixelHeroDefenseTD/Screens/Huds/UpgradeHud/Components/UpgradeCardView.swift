//
//  UpgradeCardView.swift
//  PixelHeroDefenseTD
//
//  Created by user on 25.03.2026.
//

import SwiftUI

struct UpgradeCardView: View {
  let upgrade: HeroUpgrade
  let currentStacks: Int
    var body: some View {
		VStack{
		  Image(upgrade.icon)
		  Text(upgrade.name)
			 .font(.title3.bold())
		  Text(currentStacks > 0 ? (upgrade.stepDescription ?? upgrade.description) : upgrade.description)
			 .font(.caption)
        if currentStacks > 0 {
            Text("Owned x\(currentStacks)")
                .font(.caption2)
                .foregroundStyle(.orange)
        }
		  
		  HStack{
			 Image(upgrade.targetRole.upgradeIcon)
				.resizable()
				.frame(width: 25, height: 25)
			 Text("\(upgrade.targetRole.rawValue.capitalized) Upgrade")
				.font(.footnote)
		  }
		  
		  HStack{
			 let rarity = upgrade.rarity
			 Text("\(rarity.rawValue.capitalized) Card")
				.foregroundStyle(rarity.colorForCard)
				.font(.caption)
		  }
		}
		.fontDesign(.monospaced)
		.foregroundStyle(.white.opacity(0.9))
		.padding(40)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(
		  Image("Square2")
			 .resizable()
			 .opacity(09)
			 .shadow(color: upgrade.rarity.colorForCard, radius: 10)
		)
		
    }
}

#Preview {
    UpgradeCardView(
        upgrade: HeroUpgrade(
            name: "Thorns",
            description: "Return 10% damage back",
            icon: "Thorns",
            targetRole: .knight,
            rarity: .special,
            mechanicFamily: .thorns,
            apply: { $0.thornsPercentage += 0.1 }
        ),
        currentStacks: 1
    )
}
