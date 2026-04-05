//
//  AppRouter.swift
//  PixelHeroDefenseTD
//
//  Created by user on 26.03.2026.
//

import SwiftUI

struct AppRouter: View {
  @State private var started: Bool = false
    var body: some View {
		VStack{
		  if started{
			 MainGameScene()
				.transition(.opacity)
		  }else{
			 StartScreenView(start: $started)
				.transition(.move(edge: .top).combined(with: .opacity))
				.zIndex(1)
				.allowsTightening(!started)
		  }
		  }
    }
}

#Preview {
    AppRouter()
}
