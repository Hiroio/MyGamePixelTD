//
//  ArtifactSelectHud.swift
//  PixelHeroDefenseTD
//
//  Created by user on 01.04.2026.
//

import SwiftUI

struct ArtifactSelectHud: View {
  let artifacts: [Artifact]
  let onSelect: (Artifact) -> Void
  var body: some View {
	 ZStack{
		Color.black.ignoresSafeArea().opacity(0.2)
		VStack{
		  Text("Choose Your\nReward")
			 .font(.custom("antiquity print", size: 32))
			 .multilineTextAlignment(.trailing)
		  HStack{
			 ForEach(artifacts.prefix(2)){artifact in
				Button{
				  onSelect(artifact)
				}label: {
				  ArtifactCard(artifact: artifact)
				}
			 }
		  }
		  .frame(height: 250)
		  if let last = artifacts.suffix(1).first {
			 Button{
				onSelect(last)
			 }label: {
				ArtifactCard(artifact: last)
				  .frame(width: 200, height: 250)
			 }
		  }
		}
	 }
  }
}

#Preview {
  ArtifactSelectHud(artifacts: Array(Artifact.allArtifact.shuffled().prefix(3))) { _ in }
}
