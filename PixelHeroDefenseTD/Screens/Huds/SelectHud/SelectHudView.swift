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
	 ScrollView{
		VStack{
		  ForEach(UnitRole.allCases, id: \.self){item in
			 let inRoster = heroInRoster(item)
			 Button{
				assignHero(item)
			 }label: {
				RecruitCard(heroUnit: item, inRoster: inRoster)
			 }
			 .opacity(inRoster ? 0.6 : 1)
			 .disabled(inRoster)
		  }
		}
		.fontDesign(.monospaced)
		.padding()
	 }
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
			 .scaleEffect(1)
//		  Image(heroUnit.upgradeIcon)
//			 .resizable()
//			 .rotationEffect(Angle(degrees: 70))
//			 .scaleEffect(-1.1)
		  Image(heroUnit.helmetIcon)
			 .resizable()
			 .offset(x: -40)
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
