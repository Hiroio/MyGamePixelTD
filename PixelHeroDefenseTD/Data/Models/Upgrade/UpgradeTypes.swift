//
//  UpgradeTypes.swift
//  PixelHeroDefenseTD
//

import Foundation
import SwiftUI

/// Card tier for perk draft.
enum UpgradeRarity: String, Sendable {
    case basic
    case rare
    case special
   
  
  var colorForCard: Color{
	 switch self {
	 case .basic:
		  .white
	 case .rare:
		  .mint
	 case .special:
		  .yellow
	 }
  }
}

/// Links a Rare card to the Special that unlocks it. `nil` = not tied / basic-only.
enum MechanicFamily: String, Sendable, Hashable {
    case cleave
    case thorns
    case plateArmor
    case enraged
    case knightKnockback

    case chainShot
    case freezingBow
    case multiShot
    case archerFocus

    case mageLightning
    case mageFire
    case mageFrost

    case priestHeal
    case priestVamp
    case priestPaladin
    case priestHolyGround
    case priestHolyShield

    case lancerCrit
    case lancerRam
    case lancerMount
    case lancerRicochet
    case lancerSteelHooves
}
