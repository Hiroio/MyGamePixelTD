//
//  GameHUDDelegate.swift
//  PixelHeroDefenseTD
//

import Foundation

/// Контракт: **сцена повідомляє** ViewModel про стан для SwiftUI.
protocol GameHUDDelegate: AnyObject {
    /// Нараховано монет (дельта); баланс веде ViewModel.
    func gameScene(_ scene: GameScene, reportedCoinGain delta: Int)

    func gameScene(
        _ scene: GameScene,
        reportedWaveState waveNumber: Int,
        canStartWave: Bool,
        isWaveRunning: Bool
    )

    /// Щойно завершена хвиля (індекс тієї, що була в бою); `waveNumber` у сцені вже переключений на наступну.
    func gameScene(_ scene: GameScene, didFinishWave completedWaveIndex: Int)

    func gameScene(
        _ scene: GameScene,
        reportedHeroPanelData currentHP: Double,
        maxHP: Double,
        attackRange: CGFloat,
        enemyTargetCount: Int
    )

    /// Залишилось ворогів (живі + ще не заспавнені) / усього на хвилі. Поза хвилею можна передавати 0/0.
    func gameScene(_ scene: GameScene, reportedWaveEnemyProgress remaining: Int, total: Int)

    /// Тап по слоту: `isOccupied` — у слоті є герой (відкрити HUD); інакше — порожній слот (меню найму, якщо не хвиля).
    func gameScene(_ scene: GameScene, reportedSlotTap slot: Int, isOccupied: Bool)

    /// Героя перетягнули зі слота `from` у слот `to` (swap/move).
    func gameScene(_ scene: GameScene, didMoveHeroFrom fromSlot: Int, to toSlot: Int)

    /// HP активного боса (0 / 0 якщо боса немає). Під майбутній HP bar у SwiftUI.
    func gameScene(_ scene: GameScene, reportedBossHP current: Double, totalBossHP: Double)
}
