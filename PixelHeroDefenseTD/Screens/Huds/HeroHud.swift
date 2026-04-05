//
//  HeroHud.swift
//  PixelHeroDefenseTD
//

import SwiftUI

struct HeroHud: View {
  let hero: HeroUnitModel
  let showUpgrade: Bool
  let upgradeCost: Int
  let canUpgrade: Bool
  let onUpgrade: () -> Void
  
  var body: some View {
	 ZStack {
		VStack{
		  VStack(spacing: 0) {
			 //				  MARK: HERO NAME AND LVL
			 VStack() {
				Text(hero.role.rawValue.capitalized)
				  .font(.largeTitle.bold())
				  .shadow(radius: 1, x: -5, y: 3)
				Text("Current Lvl:\(hero.stats.currentLevel)")
				  .font(.subheadline)
			 }
			 .frame(maxWidth: .infinity)
			 .padding(.vertical, 30)
			 .foregroundStyle(.white.opacity(0.8))
			 .background(
				Image("Banner3")
				  .resizable()
				  .scaledToFit()
			 )
			 VStack{
			 HStack {
				StatInfo(title: "HP", value: hero.stats.baseHP)
				StatInfo(title: "Atk", value: hero.stats.baseDamage)
				StatInfo(title: "Spd", value: hero.stats.attackSpeed)
			 }
				HStack{
				  StatInfo(title: "Kncb", value: hero.stats.knockback)
				  StatInfo(title: "Thorns", value: hero.stats.thornsPercentage)
				  StatInfo(title: "Rng", value: hero.stats.range)
				}
		  }
			 .kerning(1)
			 .foregroundStyle(.white)
			 
		  }
		  .frame(maxWidth: .infinity)
		  .padding(32)
		  .background(
			 Image("Square2")
				.resizable(resizingMode: .stretch)
				.opacity(0.9)
		  )
		  
		  UpgradeBtn
		}
		
	 }
	 .fontDesign(.monospaced)
	 .font(.caption.bold())
	 .kerning(3)
  }
  
  
  private var UpgradeBtn: some View{
	 VStack{
		if showUpgrade {
		  Button {
			 onUpgrade()
		  } label: {
			 HStack(spacing: 4) {
				Text("Upgrade")
				  .font(.title3.bold())
				Image("Coin")
				  .resizable()
				  .scaledToFit()
				  .frame(width: 25)
				Text("\(upgradeCost)")
				  .font(.subheadline.bold())
				  .opacity(0.9)
				
			 }
			 .foregroundStyle(Color.white)
			 .shadow(radius: 2)
			 .padding(.vertical)
			 .frame(maxWidth: .infinity)
			 .background(
				Image("Banner2")
				  .resizable()
				  .frame(maxWidth: .infinity)
				  .padding(.horizontal, 40)
			 )
		  }
		  .disabled(!canUpgrade)
		}
	 }
  }
}

#Preview {
  HeroHud(
	 hero: HeroUnitModel(role: .knight, stats: .knightPrototype()),
	 showUpgrade: true,
	 upgradeCost: 50,
	 canUpgrade: true,
	 onUpgrade: {}
  )
}


@ViewBuilder
func StatInfo(title: String, value: Double) -> some View{
  HStack{
	 Text("\(title): \(value.formatted(.number.precision(.fractionLength(1))))")
  }
}
