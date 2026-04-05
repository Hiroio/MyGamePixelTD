//
//  UpgradeView.swift
//  PixelHeroDefenseTD
//
//  Created by user on 25.03.2026.
//

import SwiftUI

struct UpgradeView: View {
    let upgrades: [HeroUpgrade]
    let onPick: (HeroUpgrade) -> Void
    let stackCountFor: (HeroUpgrade) -> Int

    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    UpgradeView(
		upgrades: UpgradeManager.shared.getRandom(for: [.mage], upgraded: false, mageType: .frost),
        onPick: { _ in },
        stackCountFor: { _ in 0 }
    )
}
