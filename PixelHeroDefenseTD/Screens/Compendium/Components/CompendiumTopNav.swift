//
//  CompendiumTopNav.swift
//  PixelHeroDefenseTD
//
//  Created by user on 10.04.2026.
//

import SwiftUI

struct CompendiumTopNav: View {
  @Binding var compendiumState: CompendiumStateEnum
  var body: some View {
	 HStack(spacing: 0){
		ForEach(CompendiumStateEnum.allCases){item in
		  let state = compendiumState == item
		  Button{
			 withAnimation(){
				compendiumState = item
			 }
		  }label: {
			 Image(item.icon)
				.resizable()
				.scaledToFit()
				.shadow(radius: 3, x: 5, y: 2)
				.opacity(state ? 1 : 0.85)
				.offset(y: state ? 2 : 0)
				.scaleEffect(state ? 0.98 : 1.05)
				.frame(height: 65)
				.padding(.vertical)
				.frame(maxWidth: .infinity)
				.background(
				  Image("Square")
					 .resizable()
					 .overlay(
						Group{
						  if state{
							 RoundedRectangle(cornerRadius: 20)
								.fill(.black.opacity(0.5))
								.scaledToFit()
						  }
						}
					 )
				)
		  }
		}
	 }
	 .animation(.easeInOut, value: compendiumState)
  }
}

#Preview {
  CompendiumTopNav(compendiumState: .constant(.artifacts))
}
