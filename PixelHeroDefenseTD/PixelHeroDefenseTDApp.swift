//
//  PixelHeroDefenseTDApp.swift
//  PixelHeroDefenseTD
//
//  Created by user on 22.03.2026.
//

import SwiftUI

@main
struct PixelHeroDefenseTDApp: App {
  @StateObject private var navManager = NavigationManager.shared
    var body: some Scene {
        WindowGroup {
			 AppRouter()
				.environmentObject(navManager)
        }
    }
}
