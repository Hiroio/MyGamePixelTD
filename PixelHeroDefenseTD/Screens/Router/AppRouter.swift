//
//  AppRouter.swift
//  PixelHeroDefenseTD
//
//  Created by user on 26.03.2026.
//

import SwiftUI

struct AppRouter: View {
  @EnvironmentObject private var navigationManager: NavigationManager
  @State private var started: Bool = false
  var body: some View {
	 ZStack{
		switch navigationManager.mainScreens {
		case .start:
		  StartScreenView()
			 .transition(.move(edge: .top).combined(with: .opacity))
			 .zIndex(1)
			 .allowsTightening(navigationManager.mainScreens == .start)
		case .game:
		  MainGameScene()
		}
		
		SecondaryScreens()
		  .animation(.easeInOut, value: navigationManager.secondaryScreens != nil)
	 }
	 
  }
}

#Preview {
  AppRouter()
	 .environmentObject(NavigationManager.shared)
}
