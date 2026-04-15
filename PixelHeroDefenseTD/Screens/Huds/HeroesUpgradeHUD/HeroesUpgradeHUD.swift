//
//  HeroesUpgradeHUD.swift
//  PixelHeroDefenseTD
//
//  Created by user on 14.04.2026.
//

import SwiftUI

struct HeroesUpgradeHUD: View {
  let heroes: [HeroUnitModel]
  let balance: Int
  let onUpgrade: (HeroUnitModel) -> ()
    var body: some View {
		VStack(spacing: 6){
		  ForEach(heroes){ item in
			 let available = GameBalanceConfig.heroUpgradeCost(currentLevel: item.stats.currentLevel) <= balance
			 
			 Button{
				onUpgrade(item)
			 }label: {
				Image(item.role.helmetIcon)
				  .resizable()
				  .scaledToFit()
				  .frame(width: 44, height: 44)
				  .overlay(alignment: .topLeading){
					 Group{
						if available{
						  Circle()
							 .fill(.yellow)
							 .frame(width: 10, height: 10)
							 .offset(x: 2, y: -2)
						}
					 }
				  }
				  .opacity(available ? 1 : 0.5)
			 }
			 .buttonStyle(.plain)
		  }
		}
		.padding(6)
    }
}

#Preview {
  HeroesUpgradeHUD(heroes: [.init(role: .knight, stats: .knightPrototype()), .init(role: .archer, stats: .archerPrototype())], balance: 20){hero in}
}
