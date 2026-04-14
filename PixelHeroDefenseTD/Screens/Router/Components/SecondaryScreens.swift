//
//  SecondaryScreens.swift
//  PixelHeroDefenseTD
//
//  Created by user on 10.04.2026.
//

import SwiftUI

struct SecondaryScreens: View {
  @EnvironmentObject private var navigationManager: NavigationManager
    var body: some View {
		  switch navigationManager.secondaryScreens {
		  case .settings:
			 EmptyView()
				.zIndex(1)
				.transition(.move(edge: .bottom).combined(with: .opacity))
				.allowsHitTesting(navigationManager.secondaryScreens == .settings)
		  case .compendium:
			 CompendiumView()
				.zIndex(1)
				.transition(.move(edge: .bottom).combined(with: .opacity))
				.allowsHitTesting(navigationManager.secondaryScreens == .compendium)
		  default:
			 EmptyView()
		  }
    }
}

#Preview {
    SecondaryScreens()
	 .environmentObject(NavigationManager.shared)
}
