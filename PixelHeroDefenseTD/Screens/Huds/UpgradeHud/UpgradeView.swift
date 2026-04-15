//
//  UpgradeView.swift
//  PixelHeroDefenseTD
//
//  Created by user on 25.03.2026.
//

import SwiftUI

struct UpgradeView: View {
    let upgrades: [HeroUpgrade]
    let rerollsRemaining: Int
    let skipRewardCoins: Int
    let onPick: (HeroUpgrade) -> Void
    let onReroll: () -> Void
    let onSkip: () -> Void
    let stackCountFor: (HeroUpgrade) -> Int

    var body: some View {
            VStack(spacing: 16) {
                VStack {
                    HStack {
                        ForEach(upgrades.prefix(2)) { upgrade in
                            Button {
                                onPick(upgrade)
                            } label: {
                                UpgradeCardView(upgrade: upgrade, currentStacks: stackCountFor(upgrade))
                            }
                        }
                    }
                    HStack {
                        ForEach(upgrades.suffix(upgrades.count == 3 ? 1 : 2)) { upgrade in
                            Button {
                                onPick(upgrade)
                            } label: {
                                UpgradeCardView(upgrade: upgrade, currentStacks: stackCountFor(upgrade))
                                    .frame(width: 200)
                            }
                        }
                    }
                }
                .frame(height: 650)
                .padding(.vertical)
				  
				  HStack(spacing: 12) {
						Button {
							 onReroll()
						} label: {
							 Text(rerollsRemaining > 0 ? "Reroll (1)" : "Reroll")
								  .font(.subheadline.monospaced().bold())
								  .foregroundStyle(rerollsRemaining > 0 ? .white : .gray)
								  .padding(.horizontal, 14)
								  .padding(.vertical, 10)
								  .background(
										RoundedRectangle(cornerRadius: 10)
											 .fill(Color.blue.opacity(rerollsRemaining > 0 ? 0.45 : 0.2))
								  )
						}
						.disabled(rerollsRemaining <= 0)

						Spacer(minLength: 8)

						Button {
							 onSkip()
						} label: {
							 HStack(spacing: 6) {
								  Image("Coin")
										.resizable()
										.interpolation(.none)
										.frame(width: 20, height: 20)
								  Text("Skip +\(skipRewardCoins)")
										.font(.subheadline.monospaced().bold())
							 }
							 .foregroundStyle(.white)
							 .padding(.horizontal, 14)
							 .padding(.vertical, 10)
							 .background(
								  RoundedRectangle(cornerRadius: 10)
										.fill(Color.orange.opacity(0.45))
							 )
						}
				  }
				  .padding(.horizontal, 8)

            }
				.padding()
    }
}

#Preview {
    UpgradeView(
        upgrades: UpgradeManager.shared.getRandom(
            for: [.mage],
            upgraded: false,
            mageType: .frost,
            heroRoster: [],
            draftMode: .standard
        ),
        rerollsRemaining: 1,
        skipRewardCoins: 20,
        onPick: { _ in },
        onReroll: {},
        onSkip: {},
        stackCountFor: { _ in 0 }
    )
}
