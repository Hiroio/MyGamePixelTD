//
//  MainGameSceneViewModel.swift
//  PixelHeroDefenseTD
//
//

import Combine
import Foundation
import SpriteKit
import SwiftUI

/// Дані панелі героя, що приходять зі сцени (живе HP тощо); одне оновлення замість кількох `@Published`.
struct HeroPanelRuntime {
    var currentHP: Double
    var maxHP: Double
    var attackRange: CGFloat
    var enemyTargetCount: Int
}

@MainActor
final class MainGameSceneViewModel: ObservableObject {
    let gameScene: GameScene

    /// Словник «індекс слота → герой». Порожній слот — ключа немає.
    @Published var heroesBySlot: [Int: HeroUnitModel] = [:]

    @Published var coins: Int = GameBalanceConfig.startingCoins

    @Published var waveNumber: Int = 1
    @Published var canStartWave: Bool = true
    @Published var isWaveRunning: Bool = false

    @Published var heroPanelRuntime: HeroPanelRuntime?

    @Published var waveEnemiesRemaining: Int = 0
    @Published var waveEnemiesTotal: Int = 0

    /// Для майбутнього бос-HUD; оновлюються з `GameScene` під час хвилі з босом.
    @Published var totalBossHP: Double = 0
    @Published var currentBossHP: Double = 0

    @Published var showLoseScreen: Bool = false
    @Published var showRunVictoryScreen: Bool = false

    /// Після перемоги на30-й хвилі — дозволити хвилі 31+ без «фіналу».
    @Published private(set) var endlessModeActive: Bool = false

    @Published var perkRerollsRemaining: Int = 0
    @Published var perkSkipRewardCoins: Int = 0

    /// Слот, для якого відкрито HUD (герой у цьому слоті).
    @Published var panelSlot: Int?
    @Published var showHeroPanel: Bool = false
    @Published var showHeroPickMenu: Bool = false
    @Published var showUpgradeMenu: Bool = false
    @Published var showArtifactMenu: Bool = false

    @Published var upgrades: [HeroUpgrade] = []
    @Published var artifacts: [Artifact] = []
    @Published var artifactChoices: [Artifact] = []
    @Published var activeBossKind: BossKind?

    let upgradeManager = UpgradeManager.shared

    /// Одноразові **special** перки, уже взяті в цьому забігу — не показуються у драфті знову.
    private var consumedSpecialUpgradeIDs: Set<String> = []

    private var perkDraftMode: PerkDraftMode = .standard
    private var perkDraftRoles: [UnitRole]? = nil
    private var pendingVictoryAfterArtifact: Bool = false

    var pendingEmptySlot: Int = 0

    var hasAnyHero: Bool { !heroesBySlot.isEmpty }

    init() {
        gameScene = GameScene(size: .zero)
        gameScene.scaleMode = .resizeFill
        gameScene.hudDelegate = self
        gameScene.syncHeroes(from: [:])
    }
}

// MARK: - Герої та хвиля
//
//  Ростер і економіка героїв: унікальність ролей, найм у слот, апгрейд, старт хвилі,
//  синхронізація моделі з `GameScene`.

extension MainGameSceneViewModel {
    /// Лицар може бути лише один на всю команду (у будь-якому слоті).
  
  func hasHeroInRoster(hero: UnitRole) -> Bool{
	 heroesBySlot.values.contains { $0.role == hero }
  }
  
  func canAffordHeroHire() -> Bool{
	 coins >= GameBalanceConfig.heroHireCost
  }
  
  func getRandomArtifacts() -> [Artifact]{
	 Array(Artifact.allArtifact.filter({ item in !self.artifacts.contains(where: {$0.id == item.id})}).shuffled().prefix(3))
  }

  private func applyArtifactToCurrentHeroes(_ artifact: Artifact) {
     var copy = heroesBySlot
     for (slot, var model) in copy {
        switch artifact.id {
        case .bonusMeal:
           model.stats.baseDamage *= 1.15
        case .enemyEncyclopedia:
           model.stats.critChance += 0.3
        default:
           break
        }
        copy[slot] = model
     }
     heroesBySlot = copy
     gameScene.syncHeroes(from: heroesBySlot)
  }

  func selectArtifact(_ artifact: Artifact) {
     guard !artifacts.contains(where: { $0.id == artifact.id }) else { return }
     artifacts.append(artifact)

     switch artifact.id {
     case .bonusMeal, .enemyEncyclopedia:
        applyArtifactToCurrentHeroes(artifact)
     case .luckyCoin:
        gameScene.setCoinRewardMultiplier(1.10)
     case .barricades:
        gameScene.setBarricadeEnabled(true, maxHP: 200)
     case .goldenBlacksmith, .magicLamp:
        break
     }

     artifactChoices = []
     withAnimation {
        showArtifactMenu = false
     }
     resolvePendingVictoryIfNeeded()
  }

    var heroForPanel: HeroUnitModel? {
        guard let s = panelSlot else { return nil }
        return heroesBySlot[s]
	 }

    var nextUpgradeCost: Int {
        guard let h = heroForPanel else { return GameBalanceConfig.heroUpgradeBaseCost }
		let price = GameBalanceConfig.heroUpgradeCost(currentLevel: h.stats.currentLevel)
		return artifacts.contains(where: {$0.id == .goldenBlacksmith}) ? Int(Double(price) * 0.15) : price
    }

    var canAffordUpgrade: Bool {
        coins >= nextUpgradeCost
    }

    func startWave() {
        guard hasAnyHero else { return }
        gameScene.requestStartWave()
    }

  func assignHeroToPendingSlot(hero: UnitRole){
	 guard !isWaveRunning else { return }
	 guard !hasHeroInRoster(hero: hero) else { return }
	 guard coins >= GameBalanceConfig.heroHireCost else { return }
	 let slot = min(max(pendingEmptySlot, 0), SceneLayout.heroSlotCount - 1)
	 coins -= GameBalanceConfig.heroHireCost
	 
	 var copy = heroesBySlot
     var stats = hero.stats
     if artifacts.contains(where: { $0.id == .bonusMeal }) {
        stats.baseDamage *= 1.15
     }
     if artifacts.contains(where: { $0.id == .enemyEncyclopedia }) {
        stats.critChance += 0.3
     }
	 copy[slot] = HeroUnitModel(role: hero, stats: stats)
	 heroesBySlot = copy
	 gameScene.syncHeroes(from: heroesBySlot)
	 showHeroPickMenu = false
  }

    func upgradeKnight() {
        guard !isWaveRunning else { return }
        guard let slot = panelSlot, var model = heroesBySlot[slot] else { return }

        let cost = GameBalanceConfig.heroUpgradeCost(currentLevel: model.stats.currentLevel)
        guard coins >= cost else { return }

        coins -= cost
        model.stats.currentLevel += 1
        model.stats.baseHP *= 1.0 + GameBalanceConfig.heroHPBonusRatioPerLevel
        model.stats.baseDamage *= 1.0 + GameBalanceConfig.heroDamageBonusRatioPerLevel
        model.stats.attackSpeed += GameBalanceConfig.heroAttackSpeedBonusPerLevel

        var copy = heroesBySlot
        copy[slot] = model
        heroesBySlot = copy

        gameScene.applyHeroModel(at: slot, model: model, healToFull: true)
        gameScene.playUpgradeEffect(at: slot)

        if GameBalanceConfig.isHeroPerkMilestoneLevel(model.stats.currentLevel) {
            let lastCompleted = max(0, waveNumber - 1)
            presentPerkDraft(
                mode: .mixedRareSpecial(specialChance: GameBalanceConfig.perkMixedSpecialChance),
                skipRewardCompletedWave: lastCompleted,
                roles: [model.role]
            )
        }
    }

    /// Застосувати обрану картку до героя з тією ж роллю, що й `upgrade.targetRole`.
    func applyPerkUpgrade(_ upgrade: HeroUpgrade) {
        guard let slot = heroesBySlot.first(where: { $0.value.role == upgrade.targetRole })?.key,
              var model = heroesBySlot[slot] else { return }
        upgrade.applyToStats(&model.stats)
        if upgrade.rarity == .special {
            consumedSpecialUpgradeIDs.insert(upgrade.upgradeID)
        }
        var copy = heroesBySlot
        copy[slot] = model
        heroesBySlot = copy
        gameScene.applyHeroModel(at: slot, model: model, healToFull: false)
        withAnimation(.spring(response: 0.45, dampingFraction: 0.92)) {
            showUpgradeMenu = false
        }
        resetPerkDraftPresentation()
    }

    /// Скільки разів цей апгрейд уже взятий героєм відповідної ролі.
    func upgradeStackCount(for upgrade: HeroUpgrade) -> Int {
        guard let hero = heroesBySlot.values.first(where: { $0.role == upgrade.targetRole }) else { return 0 }
        return hero.stats.upgradeStacks[upgrade.name, default: 0]
    }
}

// MARK: - SwiftUI / розмір сцени
//
//  Геометрія `GameScene`, закриття меню найму з SwiftUI.

extension MainGameSceneViewModel {
    func applySize(_ newSize: CGSize) {
        guard newSize.width > 1, newSize.height > 1 else { return }
        gameScene.size = newSize
    }

    func dismissHeroPickMenu() {
        showHeroPickMenu = false
    }

    func restartGame() {
        coins = GameBalanceConfig.startingCoins
        waveNumber = 1
        canStartWave = true
        isWaveRunning = false
        heroesBySlot = [:]
        panelSlot = nil
        showHeroPanel = false
        showHeroPickMenu = false
        showUpgradeMenu = false
        showArtifactMenu = false
        showLoseScreen = false
        showRunVictoryScreen = false
        endlessModeActive = false
        pendingVictoryAfterArtifact = false
        perkRerollsRemaining = 0
        perkSkipRewardCoins = 0
        waveEnemiesRemaining = 0
        waveEnemiesTotal = 0
        totalBossHP = 0
        currentBossHP = 0
        activeBossKind = nil
        heroPanelRuntime = nil
        artifacts = []
        artifactChoices = []
        upgrades = []
        consumedSpecialUpgradeIDs = []
        perkDraftMode = .standard
        perkDraftRoles = nil
        gameScene.setCoinRewardMultiplier(1.0)
        gameScene.setBarricadeEnabled(false, maxHP: 200)
        gameScene.removeAllChildren()
        gameScene.removeAllActions()
        gameScene.commonInitForRestart()
        gameScene.syncHeroes(from: [:])
    }
}

// MARK: - GameHUDDelegate
//
//  Колбеки з `GameScene`: монети, хвиля, дані панелі героя, прогрес ворогів, тап по слоту.

extension MainGameSceneViewModel: GameHUDDelegate {
    func gameScene(_ scene: GameScene, reportedCoinGain delta: Int) {
        coins += delta
    }

    func gameScene(
        _ scene: GameScene,
        reportedWaveState waveNumber: Int,
        canStartWave: Bool,
        isWaveRunning: Bool
    ) {
        self.waveNumber = waveNumber
        self.canStartWave = canStartWave
        self.isWaveRunning = isWaveRunning
    }

    func gameScene(_ scene: GameScene, didFinishWave completedWaveIndex: Int) {
        if BossKind.forWaveNumber(completedWaveIndex) != nil {
            if completedWaveIndex == 20, !endlessModeActive {
                pendingVictoryAfterArtifact = true
            }
            let choices = getRandomArtifacts()
            if !choices.isEmpty {
                artifactChoices = choices
                withAnimation {
                    showArtifactMenu = true
                }
            } else {
                resolvePendingVictoryIfNeeded()
            }
            return
        }

        guard !heroesBySlot.isEmpty else { return }

        let mode: PerkDraftMode
        if completedWaveIndex == GameBalanceConfig.specialOnlyPerkAfterCompletedWave {
            mode = .specialOnly
        } else if GameBalanceConfig.isMixedRareSpecialPerkRound(completedWaveIndex) {
            mode = .mixedRareSpecial(specialChance: GameBalanceConfig.perkMixedSpecialChance)
        } else {
            mode = .standard
        }
        presentPerkDraft(mode: mode, skipRewardCompletedWave: completedWaveIndex, roles: nil)
    }

    func rerollPerkDraft() {
        guard perkRerollsRemaining > 0 else { return }
        perkRerollsRemaining -= 1
        refillPerkDraftPool()
    }

    func skipPerkDraftForCoins() {
        guard showUpgradeMenu else { return }
        coins += perkSkipRewardCoins
        withAnimation(.spring(response: 0.45, dampingFraction: 0.92)) {
            showUpgradeMenu = false
        }
        resetPerkDraftPresentation()
    }

    func continueRunEndless() {
        endlessModeActive = true
        withAnimation {
            showRunVictoryScreen = false
        }
    }

    private func presentPerkDraft(mode: PerkDraftMode, skipRewardCompletedWave: Int, roles: [UnitRole]?) {
        perkDraftMode = mode
        perkDraftRoles = roles
        perkRerollsRemaining = GameBalanceConfig.perkDraftRerollsPerWindow
        perkSkipRewardCoins = GameBalanceConfig.perkSkipCoinReward(completedWaveIndex: skipRewardCompletedWave)
        refillPerkDraftPool()
        guard !upgrades.isEmpty else { return }
        withAnimation(.spring(response: 0.52, dampingFraction: 0.88)) {
            showUpgradeMenu = true
        }
    }

    private func refillPerkDraftPool() {
        let rolePool = perkDraftRoles ?? Array(Set(heroesBySlot.values.map(\.role)))
        upgrades = upgradeManager.getRandom(
            for: rolePool,
            upgraded: artifacts.contains(where: { $0.id == .magicLamp }),
            mageType: heroesBySlot.values.first(where: { $0.role == .mage })?.stats.mageType,
            consumedSpecialIDs: consumedSpecialUpgradeIDs,
            heroRoster: Array(heroesBySlot.values),
            draftMode: perkDraftMode
        )
    }

    private func resetPerkDraftPresentation() {
        perkRerollsRemaining = 0
        perkSkipRewardCoins = 0
        perkDraftMode = .standard
        perkDraftRoles = nil
    }

    private func resolvePendingVictoryIfNeeded() {
        guard pendingVictoryAfterArtifact else { return }
        pendingVictoryAfterArtifact = false
        guard !endlessModeActive else { return }
        withAnimation {
            showRunVictoryScreen = true
        }
    }

    func gameScene(
        _ scene: GameScene,
        reportedHeroPanelData currentHP: Double,
        maxHP: Double,
        attackRange: CGFloat,
        enemyTargetCount: Int
    ) {
        heroPanelRuntime = HeroPanelRuntime(
            currentHP: currentHP,
            maxHP: maxHP,
            attackRange: attackRange,
            enemyTargetCount: enemyTargetCount
        )
    }

    func gameScene(_ scene: GameScene, reportedWaveEnemyProgress remaining: Int, total: Int) {
        waveEnemiesRemaining = remaining
        waveEnemiesTotal = total
    }

    func gameScene(_ scene: GameScene, reportedBossHP current: Double, totalBossHP: Double) {
        currentBossHP = current
        self.totalBossHP = totalBossHP
        activeBossKind = totalBossHP > 0 ? BossKind.forWaveNumber(waveNumber) : nil
    }

    func gameScene(_ scene: GameScene, didMoveHeroFrom fromSlot: Int, to toSlot: Int) {
        guard !isWaveRunning else { return }
        guard fromSlot != toSlot else { return }
        var copy = heroesBySlot
        let fromHero = copy[fromSlot]
        let toHero = copy[toSlot]
        copy[fromSlot] = toHero
        copy[toSlot] = fromHero
        heroesBySlot = copy
        gameScene.syncHeroes(from: heroesBySlot)

        if let panel = panelSlot, panel == fromSlot {
            panelSlot = toSlot
            gameScene.setHUDStatsSlot(toSlot)
            gameScene.setHighlightedSlot(toSlot)
        }
    }

    func gameScene(_ scene: GameScene, reportedSlotTap slot: Int, isOccupied: Bool) {
        let sl = min(max(slot, 0), SceneLayout.heroSlotCount - 1)
        if isOccupied {
            if panelSlot == sl && showHeroPanel {
                showHeroPanel = false
                panelSlot = nil
                gameScene.setHUDStatsSlot(nil)
                gameScene.setHighlightedSlot(nil)
            } else {
                panelSlot = sl
                gameScene.setHUDStatsSlot(sl)
                gameScene.setHighlightedSlot(sl)
                showHeroPickMenu = false
                withAnimation(.easeOut(duration: 0.22)) {
                    showHeroPanel = true
                }
            }
        } else {
            if isWaveRunning { return }
            showHeroPanel = false
            panelSlot = nil
            gameScene.setHUDStatsSlot(nil)
            gameScene.setHighlightedSlot(nil)
            pendingEmptySlot = sl
            showHeroPickMenu = true
        }
    }
}
