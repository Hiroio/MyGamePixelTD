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
		  //		  MARK: Hero SelectHUD + INFO HUD
		  //		  VStack {
		  //			 if viewModel.showHeroPanel, let hero = viewModel.heroForPanel {
		  //				ZStack(alignment: .top){
		  //				  Color.black.ignoresSafeArea().opacity(0.2)
		  //					 .onTapGesture {
		  //						viewModel.showHeroPanel.toggle()
		  //					 }
		  //				  HeroHud(
		  //					 hero: hero,
		  //					 showUpgrade: true,
		  //					 upgradeCost: viewModel.nextUpgradeCost,
		  //					 canUpgrade: viewModel.canAffordUpgrade,
		  //					 onUpgrade: { viewModel.upgradeKnight(hero: hero) }
		  //				  )
		  //
		  //				}
		  //				.transition(.opacity)
		  //				.zIndex(100)
		  //				.allowsHitTesting(viewModel.showHeroPanel)
		  //				.animation(.linear, value: viewModel.showHeroPanel)
		  //			 } else {
		  //				HStack(spacing: 12) {
		  //				  Spacer()
		  //				  GameInfoHUD(waveEnemiesTotal: viewModel.waveEnemiesTotal, waveEnemiesRemaining: viewModel.waveEnemiesRemaining, waveNumber: viewModel.waveNumber, selectedArtifacts: viewModel.artifacts)
		  //				}
		  //				.font(.title2)
		  //				.fontDesign(.monospaced)
		  //			 }
		  //
		  //			 Spacer()
		  //		  }
		  //		  .frame(maxHeight: .infinity)
		  //		  .ignoresSafeArea(edges: .bottom)
		  //		  .overlay(
		  //			 //			 MARK: COINS HUD + Boss HUD
		  //			 ZStack{
		  //				topCoinHUD
		  //				if viewModel.totalBossHP != 0, let boss = viewModel.activeBossKind {
		  //					 BossHUD(totalHP: viewModel.totalBossHP, currentHP: viewModel.currentBossHP, bossName: boss)
		  //						.transition(.move(edge: .top))
		  //						.zIndex(3)
		  //						.allowsHitTesting(false)
		  //						.padding(.top, 48)
		  //				}
		  //			 }
		  //			 .animation(.easeInOut, value: viewModel.totalBossHP != 0),
		  //			 alignment: .topLeading
		  //		  )
		  //		  .background(
		  //			 Group{
		  //				//				MARK: Wave Start BTN
		  //				if !viewModel.isWaveRunning {
		  //				  VStack(alignment: .trailing, spacing: 10){
		  //					 HeroesUpgradeHUD(
		  //						heroes: viewModel.heroesBySlot
		  //						  .sorted { $0.key < $1.key }
		  //						  .map(\.value),
		  //						balance: viewModel.coins
		  //					 ) { hero in
		  //						viewModel.upgradeKnight(hero: hero)
		  //					 }
		  //					 .frame(width: 58)
		  //					 Button {
		  //						viewModel.startWave()
		  //					 } label: {
		  //						WaveStartBtn()
		  //					 }
		  //					 .disabled(!viewModel.canStartWave || !viewModel.hasAnyHero)
		  //				  }
		  //				  .padding(.trailing, 12)
		  //				  .padding(.bottom, 12)
		  //				  .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
		  //				}
		  //			 },
		  //			 alignment: .bottomTrailing
		  //		  )
		  //
		  //
		  //		  //		  MARK: CARDS UPGRADE / Artifacts / HeroPick
		  //		  if viewModel.showUpgradeMenu {
		  //			 UpgradeView(
		  //				upgrades: viewModel.upgrades,
		  //				rerollsRemaining: viewModel.perkRerollsRemaining,
		  //				skipRewardCoins: viewModel.perkSkipRewardCoins,
		  //				onPick: { choice in
		  //				  viewModel.applyPerkUpgrade(choice)
		  //				},
		  //				onReroll: { viewModel.rerollPerkDraft() },
		  //				onSkip: { viewModel.skipPerkDraftForCoins() },
		  //				stackCountFor: { upgrade in
		  //				  viewModel.upgradeStackCount(for: upgrade)
		  //				}
		  //			 )
		  //			 .frame(maxWidth: .infinity, maxHeight: .infinity)
		  //			 .transition(
		  //				.asymmetric(
		  //				  insertion: .opacity.combined(with: .scale(scale: 0.96)),
		  //				  removal: .opacity
		  //				)
		  //			 )
		  //			 .zIndex(100)
		  //			 .allowsHitTesting(viewModel.showUpgradeMenu)
		  //		  }
		  //		  //		  MARK: HERO PICK
		  //		  if viewModel.showHeroPickMenu{
		  //			 ZStack{
		  //				Color.black.opacity(0.4)
		  //				  .ignoresSafeArea()
		  //				  .onTapGesture {
		  //					 withAnimation(){
		  //						viewModel.showHeroPickMenu.toggle()
		  //					 }
		  //				  }
		  //				  .animation(.easeInOut, value: viewModel.showHeroPickMenu)
		  //				SelectHudView(heroInRoster: {hero in viewModel.hasHeroInRoster(hero: hero)}, assignHero: {hero in viewModel.assignHeroToPendingSlot(hero: hero)})
		  //
		  //			 }
		  //			 .zIndex(100)
		  //			 .allowsHitTesting(viewModel.showHeroPickMenu)
		  //		  }
		  ////		  MARK: Artifact Select
		  //		  if viewModel.showArtifactMenu{
		  //			 ArtifactSelectHud(artifacts: viewModel.artifactChoices) { artifact in
		  //				viewModel.selectArtifact(artifact)
		  //			 }
		  //		  }
		  //
		  //		  //		  MARK: LoseScreen
		  //		  if viewModel.showLoseScreen {
		  //			 LoseScreen(
		  //				onRestart: {
		  //				  viewModel.restartGame()
		  //				}
		  //			 )
		  //			 .transition(.opacity)
		  //			 .zIndex(200)
		  //		  }
		  //
		  //		  if viewModel.showRunVictoryScreen {
		  //			 RunVictoryScreen(
		  //				onContinueEndless: { viewModel.continueRunEndless() },
		  //				onRestart: { viewModel.restartGame() }
		  //			 )
		  //			 .transition(.opacity)
		  //			 .zIndex(200)
		  //		  }
		  //		}
		  //		.animation(.easeInOut, value: viewModel.showHeroPickMenu)
		  //		.animation(.easeInOut, value: viewModel.isWaveRunning)
		  //		.animation(.easeInOut, value: viewModel.showHeroPanel)
		  //		.animation(.spring(response: 0.5, dampingFraction: 0.88), value: viewModel.showUpgradeMenu)
		  //		.animation(.easeInOut, value: viewModel.showRunVictoryScreen)
		  //		.onAppear {
		  //		  viewModel.applySize(proxy.size)
		  //		}
		  //		.onChange(of: proxy.size) { _, newSize in
		  //		  viewModel.applySize(newSize)
		  //		}
		  //	 }
		  //  }
		  //
		  //  private var topCoinHUD: some View {
		  //	 HStack(spacing: 6) {
		  //		Image("Coin")
		  //		  .resizable()
		  //		  .interpolation(.none)
		  //		  .frame(width: 25, height: 25)
		  //		Text("\(viewModel.coins)")
		  //		  .font(.system(size: 13, weight: .semibold, design: .monospaced))
		  //		  .foregroundStyle(.white)
		  //	 }
		  //	 .padding(.horizontal, 10)
		  //	 .padding(.vertical, 6)
		  //	 .background(Color.black.opacity(0.45))
		  //	 .overlay(
		  //		Rectangle()
		  //		  .stroke(Color.white.opacity(0.3), lineWidth: 1)
		  //	 )
		  //	 .padding(.top, 12)
		  //	 .padding(.leading, 14)
		  //	 .frame(maxWidth: .infinity, alignment: .leading)
		  //	 .allowsHitTesting(false)
		}
	 }
  }
}

#Preview {
  MainGameScene()
}
