//
//  ArtifactCompendium.swift
//  PixelHeroDefenseTD
//
//  Created by user on 13.04.2026.
//

import SwiftUI

struct ArtifactCompendium: View {
    var body: some View {
        ZStack{
			 Color.black.opacity(0.3)
			 .ignoresSafeArea()
		  ScrollView{
			 LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)){
				ForEach(ArtifactID.allCases, id: \.self){item in
				  Button{
					 withAnimation(){
						
					 }
				  }label: {
					 artifactCard(artifact: item)
				  }
				}
			 }
		  }
		  .padding()
		}
    }
}

@ViewBuilder
func artifactCard(artifact: ArtifactID) -> some View {
  VStack{
	 Image(artifact.icon)
		.resizable()
		.scaledToFit()
		.shadow(radius: 2, x: 5, y: 2)
		.padding()
		.background(
		  Image("Square2")
			 .resizable()
		)
	 
	 Text(artifact.text)
		.font(.title2.monospaced().bold())
		.foregroundStyle(.yellow)
	 
	 Text(artifact.description)
		.font(.caption)
		.foregroundStyle(.white)
  }
  .padding()
  .frame(maxWidth: .infinity)
  .frame(height: 250)
  .background(
	 Image("Box")
		.resizable()
  )
}

#Preview {
    ArtifactCompendium()
}
