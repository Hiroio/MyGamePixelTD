//
//  CompendiumView.swift
//  PixelHeroDefenseTD
//
//  Created by user on 10.04.2026.
//

import SwiftUI

struct CompendiumView: View {
  @EnvironmentObject private var navMan: NavigationManager
    var body: some View {
		ZStack(alignment: .top){
		  Color.brown.ignoresSafeArea()
		  VStack(spacing: 0){
			 CompendiumTopNav(compendiumState: $navMan.compendiumState)
			 
			 switch navMan.compendiumState {
			 case .heroes:
				HeroesCompendium()
			 case .enemies:
				EnemiesCompendium()
			 case .artifacts:
				ArtifactCompendium()
			 case .support:
				EmptyView()
			 }
			 
			 
		  }
		}
    }
}

#Preview {
    CompendiumView()
	 .environmentObject(NavigationManager.shared)
}
