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
		  if started{
			 MainGameScene()
				.transition(.opacity)
		  }else{
			 StartScreenView(start: $started)
				.transition(.move(edge: .top).combined(with: .opacity))
				.zIndex(1)
				.allowsTightening(!started)
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
