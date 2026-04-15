//
//  GameInfoHUD.swift
//  PixelHeroDefenseTD
//
//  Created by user on 01.04.2026.
//

import SwiftUI

struct SomeGameInfo: View {
  @EnvironmentObject var vm: MainGameSceneViewModel
  var body: some View {
	 VStack{
		HStack{
		  coinHUD
		  Spacer()
		  gameInfo
		}
		.padding(.horizontal)
		Spacer()
		
		VStack{
		  if vm.screenState == nil && !vm.isWaveRunning {
			 HeroesUpgradeHUD(heroes: Array(vm.heroesBySlot.values), balance: vm.coins, onUpgrade: {hero in
				vm.upgradeKnight(hero: hero)
			 })
			 .frame(maxWidth: .infinity, alignment: .bottomTrailing)
			 .transition(.move(edge: .trailing).combined(with: .opacity))
			 
			 VStack(alignment: .trailing, spacing: 10){
				Button {
				  vm.startWave()
				} label: {
				  WaveStartBtn()
				}
				.disabled(!vm.canStartWave || !vm.hasAnyHero)
			 }
			 .padding(.trailing, 12)
			 .padding(.bottom, 12)
			 .frame(maxWidth: .infinity, alignment: .bottomTrailing)
			 .transition(.move(edge: .bottom).combined(with: .opacity))
		  }
		}
		.zIndex(1)
		.allowsHitTesting(vm.screenState == nil)
		
	 }
	 
  }
  
//  Coins
  private var coinHUD: some View{
	 HStack(spacing: 6) {
		Image("Coin")
		  .resizable()
		  .interpolation(.none)
		  .frame(width: 25, height: 25)
		Text("\(vm.coins)")
		  .font(.system(size: 13, weight: .semibold, design: .monospaced))
		  .foregroundStyle(.white)
		  .contentTransition(.numericText())
	 }
	 .padding()
	 .background(
		Image("Banner4")
		  .resizable()
		  .scaledToFit()
		  .shadow(radius: 3, y: 3)
	 )
	 .frame(maxWidth: .infinity, alignment: .leading)
	 .allowsHitTesting(false)
  }
  
//  Waves + Enimies
  private var gameInfo: some View{
	 VStack(alignment: .trailing){
		HStack(spacing: 6) {
		  if vm.waveEnemiesTotal > 0 {
			 Text("\(vm.waveEnemiesRemaining)/\(vm.waveEnemiesTotal)")
				.font(.title2.monospaced().bold())
		  } else {
			 Text("—")
				.font(.title3.monospaced())
				.foregroundStyle(.secondary)
		  }
		  Image("Enemies")
			 .resizable()
			 .scaledToFit()
			 .frame(width: 35, height: 35)
		}
		
		HStack(spacing: 6) {
		  Text("\(vm.waveNumber)")
			 .font(.title2.monospaced().bold())
		  Image("Wave")
			 .resizable()
			 .scaledToFit()
			 .frame(width: 35, height: 35)
		}
		
		
		ForEach(vm.artifacts){artifact in
		  Image(artifact.icon)
			 .resizable()
			 .scaledToFit()
			 .frame(width: 50, height: 50)
		}
	 }
  }
}
