//
//  LoseScreen.swift
//  PixelHeroDefenseTD
//
//  Created by user on 26.03.2026.
//

import SwiftUI

struct LoseScreen: View {
  let onRestart: () -> Void
  var body: some View {
	 ZStack{
		Color.black.ignoresSafeArea().opacity(0.4)
		VStack(spacing: 25){
		  Text("Score:")
			 .font(.title2)
			 .monospaced()
		  
		  ZStack{
			 Image("Blood")
				.resizable().scaledToFit()
				.opacity(0.9)
				.scaleEffect(1.2)
			 
			 Image("Skull")
				.resizable().scaledToFit()
		  }
		  .frame(width: 150)
		  Text("You Lose..")
			 .font(.custom("antiquity-print", size: 45))
			 .shadow(color: .black, radius: 2, x: -5, y: 3)
			 .foregroundStyle(.red)
		  VStack{
			 Button{
				
			 }label: {
				Text("Exit")
				  .foregroundStyle(.red)
				  .padding()
				  .monospaced()
				  .padding(.horizontal, 50)
				  .background(
					 Image("Banner4")
						.resizable()
				  )
			 }
			 
			 Button{
				onRestart()
			 }label: {
				Text("Restart")
				  .foregroundStyle(.white)
				  .monospaced()
				  .padding()
				  .padding(.horizontal, 50)
				  .background(
					 Image("Banner4")
						.resizable()
				  )
			 }
		  }
		}
		.kerning(2)
		.fontWeight(.bold)
	 }
	 
  }
}

#Preview {
    LoseScreen(onRestart: {})
}
