//
//  EnemiesCompendium.swift
//  PixelHeroDefenseTD
//
//  Created by user on 10.04.2026.
//

import SwiftUI

struct EnemiesCompendium: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()

            TimelineView(.periodic(from: .now, by: 0.2)) { timeline in
                let tick = Int(timeline.date.timeIntervalSinceReferenceDate / 0.12)
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(EnemyType.allCases) { enemy in
                            EnemyCompendiumIcon(enemy: enemy, tick: tick)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Cell

private struct EnemyCompendiumIcon: View {
    let enemy: EnemyType
    let tick: Int
  let bosses: [EnemyType] = [.kingSlimeBoss , .eliteOrcBoss, .armoredSkeletonBoss]
    var body: some View {
        let frames = enemy.iconAnimation
		VStack{
		  Group {
			 if frames.isEmpty {
				RoundedRectangle(cornerRadius: 8)
				  .fill(Color.gray.opacity(0.25))
				  .overlay {
					 Image(systemName: "photo")
						.foregroundStyle(.secondary)
				  }
			 } else {
				Image(uiImage: frames[tick % frames.count])
				  .resizable()
				  .scaledToFit()
				  .scaleEffect(bosses.contains(enemy) ? 2.5 : 1.5)
			 }
		  }
		  .frame(width: 100, height: 100)
		  Text(enemy.rawValue.capitalized)
			 .font(.custom("antiquity-print", size: 12))
			 .foregroundStyle(.gray)
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical)
		.background(
		  Image("Square2")
			 .resizable()
		)
		.padding()
    }
}

#Preview {
    EnemiesCompendium()
}
