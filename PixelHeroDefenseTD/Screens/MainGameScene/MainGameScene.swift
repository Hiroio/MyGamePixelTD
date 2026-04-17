//
//  MainGameScene.swift
//  PixelHeroDefenseTD
//

import SpriteKit
import SwiftUI

struct MainGameScene: View {
  @StateObject private var viewModel = MainGameSceneViewModel()
  
  var body: some View {
	 GeometryReader { proxy in
		ZStack(alignment: .top) {
		  SpriteView(scene: viewModel.gameScene)
			 .ignoresSafeArea()
		  
		  
		  HUDScreensView()
			 .environmentObject(viewModel)
		}
	 }
  }
}

#Preview {
  MainGameScene()
}
