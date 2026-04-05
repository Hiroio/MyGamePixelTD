//
//  StartScreenView.swift
//  PixelHeroDefenseTD
//
//  Created by user on 23.03.2026.
//

import SwiftUI

struct StartScreenView: View {
  @State private var animate: Bool = false
  @Binding var start: Bool
    var body: some View {
		ZStack{
		  Image("background")
			 .resizable()
			 .scaledToFill()
			 .offset(x: animate ? 5.0 : -5)
			 .ignoresSafeArea()
		  VStack{
			 Text("Pixel Hero\nDefence TD")
				.font(.custom("antiquity-print", size: 32))
				.multilineTextAlignment(.trailing)
				.shadow(color: .black.opacity(0.3), radius: 4, x: -5, y: 5)
				.foregroundStyle(.green.mix(with: .black, by: 0.3))
			 Spacer()
			 Spacer()
			 Button{
				withAnimation(){
				  start.toggle()
				}
			 }label: {
				Text("Start")
				  .foregroundStyle(.white.opacity(animate ? 0.7 : 1))
				  .shadow(color: .black.opacity(0.4),radius: 2, x: -5, y: 8)
				  .font(.custom("antiquity-print", size: 24))
			 }
			 .frame(maxWidth: .infinity)
			 .overlay(
				HStack{
				  Button{}label: {
					 Image("Encyclopedia")
						.shadow(radius: 2, x: -3, y: 3)
				  }
				  Spacer()
				  Button{}label: {
					 Image("Settings")
						.shadow(radius: 2, x: -3, y: 3)
				  }
				}
			 .frame(height: 55)
			 .padding(.horizontal)
			 )
		  }
		  .containerRelativeFrame(.horizontal) { size, axis in
								size
						  }
		}
		
		.onAppear(){
		  withAnimation(.easeInOut(duration: 2.5).repeatForever()){
			 animate = true
		  }
		}
    }
}

#Preview {
  StartScreenView(start: .constant(false))
}
