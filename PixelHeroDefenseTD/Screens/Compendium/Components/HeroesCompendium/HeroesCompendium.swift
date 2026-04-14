//
//  HeroesCompendium.swift
//  PixelHeroDefenseTD
//
//  Created by user on 10.04.2026.
//

import SwiftUI

struct HeroesCompendium: View {
  @State private var selectedHero: UnitRole? = nil
    var body: some View {
		ZStack{
		  Color.black.opacity(0.3)
			 .ignoresSafeArea()
		  ScrollView{
			 LazyVStack{
				ForEach(UnitRole.allCases, id: \.self){item in
				  Button{
					 withAnimation(){
						if selectedHero == item{
						  selectedHero = nil
						}else{
						  selectedHero = item
						}
					 }
				  }label: {
					 heroCard(unit: item, isActive: selectedHero == item)
						.underline(!(selectedHero == item))
						.foregroundStyle(selectedHero == item ? .yellow : .gray)
				  }
				}
			 }
		  }
		  .padding()
		}
    }
}

@ViewBuilder
func heroCard(unit: UnitRole, isActive: Bool) -> some View{
  VStack(spacing: 0){
	 HStack{
		Image(unit.helmetIcon)
		VStack{
		  Text(unit.rawValue.capitalized)
			 .font(.custom("antiquity-print", size: 24))
		}
		Image(unit.helmetIcon)
	 }
	 .padding()
	 .frame(maxWidth: .infinity)
	 .background(
		Image("Square2")
		  .resizable()
		
	 )
	 if isActive{
		VStack{
		  Text(unit.name)
			 .font(.custom("antiquity-print", size: 24))
		  Text(unit.bio)
			 .font(.footnote.monospaced())
		  Divider()
		  Text(unit.description)
			 .monospaced()
		}
		.padding()
		.frame(maxWidth: .infinity)
		.background(
		  Image("Box")
			 .resizable()
		)
		.padding(.horizontal)
	 }
  }
}

#Preview {
    HeroesCompendium()
}
