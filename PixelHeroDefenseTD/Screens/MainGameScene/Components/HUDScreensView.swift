//
//  HUDScreensView.swift
//  PixelHeroDefenseTD
//
//  Created by user on 15.04.2026.
//

import SwiftUI

struct HUDScreensView: View {
  @EnvironmentObject private var vm: MainGameSceneViewModel
  var body: some View {
	 ZStack{
		SomeGameInfo()
		
		Group{
		if vm.screenState != nil{
		  Color.black.opacity(0.3)
			 .ignoresSafeArea()
			 .transition(.opacity)
			 .onTapGesture {
				if vm.screenState == .heroSelection{
				  vm.screenState = nil
				}
			 }
		}
		
		  switch vm.screenState {
		  case .upgrade:
			 UpgradeCards
		  case .artifacts:
			 ArtifactSelectHud(artifacts: vm.artifactChoices) { artifact in
				vm.selectArtifact(artifact)
			 }
		  case .heroPick:
			 HeroPick
		  case .heroSelection:
			 HeroSelection
		  case .lose:
			 LoseScreen(
				onRestart: {
				  vm.restartGame()
				}
			 )
			 .transition(.opacity)
		  case .win:
			 RunVictoryScreen(
				onContinueEndless: { vm.continueRunEndless() },
				onRestart: { vm.restartGame() }
			 )
		  default:
			 EmptyView()
		  }
		}
		.allowsHitTesting(vm.screenState != nil)
		
	 }
	 .animation(.bouncy(duration: 0.8), value: vm.screenState != nil)
  }
  
  //  HERO PICKER
  private var HeroPick: some View{
	 ZStack(alignment:.bottom){
		SelectHudView(heroInRoster: {hero in vm.hasHeroInRoster(hero: hero)}, assignHero: {hero in vm.assignHeroToPendingSlot(hero: hero)})
		
		Text("Close")
		  .font(.title3.monospaced())
		  .foregroundStyle(.white)
		  .padding()
		  .background(
			 RoundedRectangle(cornerRadius: 15)
				.fill(.black.opacity(0.6))
		  )
		  .onTapGesture {
			 withAnimation(){
				vm.screenState = nil
			 }
		  }
	 }
	 .transition(.move(edge: .bottom))
	 .zIndex(1)
	 .allowsHitTesting(vm.screenState == .heroPick)
	 
  }
  
  //  Hero SELECTION
  private var HeroSelection: some View{
	 VStack{
		if let hero = vm.heroForPanel{
		  HeroHud(
			 hero: hero,
			 showUpgrade: true,
			 upgradeCost: vm.nextUpgradeCost,
			 canUpgrade: vm.canAffordUpgrade,
			 onUpgrade: { vm.upgradeHero(hero: hero) }
		  )
		}
	 }
	 .padding()
	 .transition(.move(edge: .bottom).combined(with: .opacity))
	 .zIndex(1)
	 .allowsHitTesting(vm.screenState == .heroSelection)
	 
  }
  
  //  UPGRADE CARDS
  private var UpgradeCards: some View{
	 UpgradeView(upgrades: vm.upgrades, rerollsRemaining: vm.perkRerollsRemaining, skipRewardCoins: vm.perkSkipRewardCoins, onPick: { choice in
		vm.applyPerkUpgrade(choice)
	 }, onReroll: { vm.rerollPerkDraft() }, onSkip: { vm.skipPerkDraftForCoins() }, stackCountFor: { upgrade in
		vm.upgradeStackCount(for: upgrade)
	 })
	 .transition(.move(edge: .bottom).combined(with: .opacity))
  }
  
  
}


@ViewBuilder
func MainLayoutView(vm: MainGameSceneViewModel)-> some View{
  
}

#Preview {
  HUDScreensView()
	 .environmentObject(MainGameSceneViewModel())
}
