//
//  NavigationManager.swift
//  PixelHeroDefenseTD
//
//  Created by user on 31.03.2026.
//

import Foundation
import Combine

class NavigationManager: ObservableObject{
  static let shared = NavigationManager()
  
  private init() {}
  
  @Published var mainScreens: MainScreensEnum = .start
  
  @Published var secondaryScreens: SecondaryScreensEnum? = nil
  
  @Published var compendiumState: CompendiumStateEnum = .heroes
}


enum MainScreensEnum{
  case start, game
}

enum SecondaryScreensEnum{
  case settings, compendium
}
enum CompendiumStateEnum: String, Identifiable, CaseIterable{
  case heroes, enemies, artifacts, support
  
  var id: String{
	 self.rawValue
  }
  
  var icon: String{
	 switch self {
	 case .heroes:
		"HeavyArmor"
	 case .enemies:
		"Skull"
	 case .artifacts:
		"Bank"
	 case .support:
		"Support"
	 }
  }
}



