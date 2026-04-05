//
//  SelectHudView.swift
//  PixelHeroDefenseTD
//
//  Created by user on 26.03.2026.
//

import SwiftUI

struct SelectHudView: View {
  let heroInRoster: (UnitRole) -> Bool
  let assignHero: (UnitRole) -> ()
    var body: some View {
		VStack{
		  Button{
			 assignHero(.knight)
		  }label: {
			 RecruitCard(heroUnit: .knight, inRoster: heroInRoster(.knight))
		  }
		  .opacity(heroInRoster(.knight) ? 0.6 : 1)
		  Button{
			 assignHero(.archer)
		  }label: {
			 RecruitCard(heroUnit: .archer, inRoster: heroInRoster(.archer))
		  }
		  .opacity(heroInRoster(.archer) ? 0.6 : 1)
		  Button{
			 assignHero(.mage)
		  }label: {
			 RecruitCard(heroUnit: .mage, inRoster: heroInRoster(.mage))
		  }
		  .opacity(heroInRoster(.mage) ? 0.6 : 1)
		  .disabled(heroInRoster(.mage))
		}
		.fontDesign(.monospaced)
		.padding()
    }
}

#Preview {
    SelectHudView(heroInRoster: { _ in return false}, assignHero: {_ in})
}


@ViewBuilder
func RecruitCard(heroUnit: UnitRole, inRoster: Bool) -> some View{
  HStack(spacing: 10){
	 ZStack{
		ZStack{
		  Image(heroUnit.upgradeIcon)
			 .resizable()
		  Image(heroUnit.upgradeIcon)
			 .resizable()
			 .rotation3DEffect(Angle(degrees: 270), axis: (x: 0, y: 0, z: 1))
		  Image(heroUnit.helmetIcon)
			 .resizable()
		}
		.frame(width: 100, height: 100)
	 }
	 .frame(width: 100, height: 120)
	 .padding(5)
	 .scaledToFit()
	 .compositingGroup()
	 .shadow(radius: 5)
	 
	 VStack(spacing: 10){
		Text(heroUnit.rawValue.capitalized)
		  .font(.title2.bold())
		if inRoster{
		  Text("Already fighting")
			 .font(.subheadline.bold())
		}else{
		  HStack(spacing: 4) {
			 Image("Coin")
				.resizable()
				.interpolation(.none)
				.frame(width: 25, height: 25)
			 Text("\(GameBalanceConfig.heroHireCost)")
				.font(.subheadline.monospaced())
		  }
		}
	 }
	 .shadow(color: .black, radius: 3, x: 3, y: 3)
	 .kerning(1)
  }
  .foregroundStyle(.white)
  .frame(width: 350)
  .background(
	 Image("Banner3")
		.resizable()
  )
  .scaledToFit()
  
}
