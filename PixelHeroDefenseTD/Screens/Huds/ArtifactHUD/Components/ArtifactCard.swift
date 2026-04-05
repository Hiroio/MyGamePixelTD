//
//  ArtifactCard.swift
//  PixelHeroDefenseTD
//
//  Created by user on 01.04.2026.
//

import SwiftUI

struct ArtifactCard: View {
  let artifact: Artifact
    var body: some View {
		VStack{
		  Image(artifact.icon)
		  Text(artifact.name)
			 .font(.title3.bold())
		  Text(artifact.description)
			 .font(.caption)
		}
		.fontDesign(.monospaced)
		.foregroundStyle(.white.opacity(0.9))
		.padding(40)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(
		  Image("Square3")
			 .resizable()
			 .opacity(0.9)
			 .shadow(color: .yellow, radius: 10)
		)
		
	 }
}

#Preview {
  ArtifactCard(artifact: Artifact.allArtifact.first!)
}
