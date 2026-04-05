//
//  GameInfoHUD.swift
//  PixelHeroDefenseTD
//
//  Created by user on 01.04.2026.
//

import SwiftUI

struct GameInfoHUD: View {
  let waveEnemiesTotal: Int
  let waveEnemiesRemaining: Int
  let waveNumber: Int
  let selectedArtifacts: [Artifact]
    var body: some View {
		VStack(alignment: .trailing){
		  HStack(spacing: 6) {
			 if waveEnemiesTotal > 0 {
				Text("\(waveEnemiesRemaining)/\(waveEnemiesTotal)")
				  .font(.title2.monospaced().bold())
			 } else {
				Text("—")
				  .font(.title3.monospaced())
				  .foregroundStyle(.secondary)
			 }
			 Image("Enemies")
				.resizable()
				.scaledToFit()
				.frame(width: 35, height: 35)
		  }
		  
		  HStack(spacing: 6) {
			 Text("\(waveNumber)")
				.font(.title2.monospaced().bold())
			 Image("Wave")
				.resizable()
				.scaledToFit()
				.frame(width: 35, height: 35)
		  }
		}
		
		ForEach(selectedArtifacts){artifact in
		  Image(artifact.icon)
			 .resizable()
			 .scaledToFit()
			 .frame(width: 50, height: 50)
		}
    }
}

#Preview {
  GameInfoHUD(waveEnemiesTotal: 5, waveEnemiesRemaining: 2, waveNumber: 1, selectedArtifacts: Array(Artifact.allArtifact.prefix(2)))
}
