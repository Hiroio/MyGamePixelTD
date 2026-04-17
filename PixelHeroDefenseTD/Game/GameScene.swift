//
//  GameScene.swift
//  PixelHeroDefenseTD
//

import SpriteKit

final class GameScene: SKScene {
    weak var hudDelegate: GameHUDDelegate?

    private let backgroundNode = BattlefieldBackgroundNode()
    private var slotFrames: [Int: HeroSlotFrameNode] = [:]
    private var heroBySlot: [Int: (SKNode & HeroUnitNode)] = [:]
    private var enemies: [BaseEnemyNode] = []
    private var coinRewardMultiplier: Double = 1.0
    private var barricadeEnabled = false
    private var barricadeMaxHP: Double = 200
    private var barricadeCurrentHP: Double = 0
    private var barricadeNode: SKSpriteNode?
    /// Щит святого жреця для слотів 0…2; знімається та наклається на старт кожної хвилі.
    private var holyShieldBySlot: [Int: Double] = [:]
    private var holyShieldMaxBySlot: [Int: Double] = [:]
    private var holyShieldVisualBySlot: [Int: HolyShieldHeroVisual] = [:]

    private var hudStatsSlot: Int?
    private var highlightedSlot: Int?

    private var lastUpdateTime: TimeInterval = 0
    private var waveNumber: Int = 1
    private var waveEnemiesLeftToSpawn: Int = 0
    private var waveTotalEnemies: Int = 0
    private var spawnsCompletedThisWave: Int = 0
    private var spawnCooldown: TimeInterval = 0
    private var isWaveRunning = false
    private var canStartWave = true

    private var draggingSlot: Int?
    /// Підсвітка всіх слотів як зона дропу під час перетягування.
    private var slotDragDropMode = false
    private var pendingDragSlot: Int?
    private var touchBeganLocation: CGPoint = .zero
    private var longPressWorkItem: DispatchWorkItem?

    /// Тривалість long press перед перетягуванням (~UIScrollView / accessibility).
    private static let heroDragLongPressDuration: TimeInterval = 1.75
    /// Якщо палець змістився раніше — скасовуємо long press (лишиться короткий тап).
    private static let longPressMovementCancelDistance: CGFloat = 18

    override init(size: CGSize) {
        super.init(size: size)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInitForRestart() {
        removeAllChildren()
        heroBySlot.removeAll()
        enemies.removeAll()
        slotFrames.removeAll()
        barricadeNode = nil
        barricadeCurrentHP = 0
        barricadeEnabled = false
        holyShieldBySlot = [:]
        holyShieldMaxBySlot = [:]
        holyShieldVisualBySlot.removeAll()
        coinRewardMultiplier = 1.0
        hudStatsSlot = nil
        highlightedSlot = nil
        cancelHeroLongPress()
        draggingSlot = nil
        slotDragDropMode = false
        pendingDragSlot = nil
        lastUpdateTime = 0
        waveNumber = 1
        waveEnemiesLeftToSpawn = 0
        waveTotalEnemies = 0
        spawnsCompletedThisWave = 0
        spawnCooldown = 0
        isWaveRunning = false
        canStartWave = true
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = .black
        layoutScene()
        pushWaveStateToHUD()
        pushBossHPToHUD()
    }

    private func commonInit() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = .black
    }

    // MARK: - Публічний API для ViewModel

    func setHUDStatsSlot(_ slot: Int?) {
        hudStatsSlot = slot
        refreshPanelAttackRangeOverlay()
    }

    func setHighlightedSlot(_ slot: Int?) {
        highlightedSlot = slot
        refreshSlotHighlights()
    }

    /// Синхронізувати героїв зі словником слот → модель.
    func syncHeroes(from slots: [Int: HeroUnitModel]) {
        for i in 0..<SceneLayout.heroSlotCount {
            if let model = slots[i] {
                if let node = heroBySlot[i] {
                    node.applyModel(model, healToFull: false)
                } else {
                    let newNode: (SKNode & HeroUnitNode)
                    switch model.role {
                    case .knight:
                        newNode = KnightHeroNode(model: model)
                    case .archer:
                        newNode = ArcherHeroNode(model: model)
                    case .mage:
                        newNode = MageHeroNode(model: model)
						  case .priest:
							 newNode = PriestHeroNode(model: model)
						  case .lancer:
							 newNode = LancerHeroNode(model: model)
//							 TO ADD
                    }
                    newNode.zPosition = 30
                    heroBySlot[i] = newNode
                    addChild(newNode)
                }
            } else if let node = heroBySlot[i] {
                holyShieldVisualBySlot.removeValue(forKey: i)
                node.removeFromParent()
                heroBySlot.removeValue(forKey: i)
                holyShieldBySlot.removeValue(forKey: i)
                holyShieldMaxBySlot.removeValue(forKey: i)
            }
        }
        layoutHeroesAndFrames()
        refreshPanelAttackRangeOverlay()
        updateHolyShieldPresentations()
    }

    func applyHeroModel(at slot: Int, model: HeroUnitModel, healToFull: Bool) {
        heroBySlot[slot]?.applyModel(model, healToFull: healToFull)
        if hudStatsSlot == slot {
            refreshPanelAttackRangeOverlay()
        }
    }

    func playUpgradeEffect(at slot: Int) {
        heroBySlot[slot]?.playUpgradeFeedback()
    }

    func setCoinRewardMultiplier(_ multiplier: Double) {
        coinRewardMultiplier = max(0.1, multiplier)
    }

    func setBarricadeEnabled(_ enabled: Bool, maxHP: Double) {
        barricadeEnabled = enabled
        barricadeMaxHP = max(1, maxHP)
        if enabled {
            ensureBarricadeExists(restoreHP: true)
        } else {
            barricadeCurrentHP = 0
            barricadeNode?.removeFromParent()
            barricadeNode = nil
        }
    }

    override func didMove(to view: SKView) {
        view.ignoresSiblingOrder = false
        layoutScene()
        pushWaveStateToHUD()
        pushHeroPanelToHUD()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutScene()
    }

    func requestStartWave() {
        guard canStartWave, !isWaveRunning, !heroBySlot.isEmpty else { return }
        canStartWave = false
        isWaveRunning = true
        if BossKind.forWaveNumber(waveNumber) != nil {
            waveTotalEnemies = 1
            waveEnemiesLeftToSpawn = 1
        } else {
            let total = GameBalanceConfig.enemyCount(forWave: waveNumber)
            waveTotalEnemies = total
            waveEnemiesLeftToSpawn = total
        }
        spawnsCompletedThisWave = 0
        spawnCooldown = GameBalanceConfig.spawnIntervalAfter(spawnsAlreadyDone: 0)
        if barricadeEnabled {
            ensureBarricadeExists(restoreHP: true)
        }
        refreshHolyShieldsForWaveStart()
        updateHolyShieldPresentations()
        pushWaveStateToHUD()
        refreshSlotFramesVisibility()
    }

    private func layoutScene() {
        guard size.width > 1, size.height > 1 else { return }

        backgroundNode.zPosition = -1000
        backgroundNode.rebuild(in: size)
        if backgroundNode.parent == nil { addChild(backgroundNode) }
        if barricadeEnabled, barricadeCurrentHP > 0 {
            ensureBarricadeExists(restoreHP: false)
        } else {
            barricadeNode?.removeFromParent()
            barricadeNode = nil
        }

        let slotSize = SceneLayout.heroSlotSize(in: size)
        for i in 0..<SceneLayout.heroSlotCount {
            if let frame = slotFrames[i] {
                frame.updateBounds(size: slotSize)
            } else {
                let frame = HeroSlotFrameNode(size: slotSize)
                frame.zPosition = 8
                slotFrames[i] = frame
                addChild(frame)
            }
        }

        for node in heroBySlot.values {
            node.updateScale(forSceneHeight: size.height)
        }
        layoutHeroesAndFrames()
        updateBarricadeLayout()
        refreshSlotHighlights()
        refreshSlotFramesVisibility()
        refreshPanelAttackRangeOverlay()
    }

    private func layoutHeroesAndFrames() {
        guard size.width > 1, size.height > 1 else { return }
        for i in 0..<SceneLayout.heroSlotCount {
            let center = SceneLayout.heroSlotCenter(slotIndex: i, in: size)
            slotFrames[i]?.position = center
            heroBySlot[i]?.position = center
            heroBySlot[i]?.updateScale(forSceneHeight: size.height)
        }
    }

    private func refreshSlotHighlights() {
        for i in 0..<SceneLayout.heroSlotCount {
            slotFrames[i]?.setDragDropTargetsActive(slotDragDropMode)
            slotFrames[i]?.setHighlighted(highlightedSlot == i)
        }
    }

    /// Рамки слотів ховаються під час хвилі (прозорі), поза хвилею видимі.
    private func refreshSlotFramesVisibility() {
        let visible = !isWaveRunning
        for i in 0..<SceneLayout.heroSlotCount {
            slotFrames[i]?.setSlotsVisible(visible)
        }
    }

    /// Коло радіусу для слота з відкритим HUD (коло не інтерактивне — лише візуал).
    private func refreshPanelAttackRangeOverlay() {
        guard size.height > 1 else { return }
        for (_, hero) in heroBySlot {
            hero.setPanelAttackRangeVisible(false, radius: 0)
        }
        guard let s = hudStatsSlot, let hero = heroBySlot[s] else { return }
        let r = hero.combatRange * SceneLayout.combatReachMultiplier(for: size.height)
        hero.setPanelAttackRangeVisible(true, radius: r)
    }

    private func ensureBarricadeExists(restoreHP: Bool) {
        guard barricadeEnabled else { return }
        if restoreHP || barricadeCurrentHP <= 0 {
            barricadeCurrentHP = barricadeMaxHP
        }

        if barricadeNode == nil {
            let tex = SKTexture(imageNamed: "BaricadeSprite")
            if tex.size().width > 0, tex.size().height > 0 {
                tex.filteringMode = .nearest
                barricadeNode = SKSpriteNode(texture: tex)
            } else {
                barricadeNode = SKSpriteNode(color: SKColor(red: 0.55, green: 0.35, blue: 0.18, alpha: 1), size: CGSize(width: 56, height: 36))
            }
            barricadeNode?.name = "barricade"
            barricadeNode?.zPosition = 24
            if let node = barricadeNode {
                addChild(node)
            }
        }
        updateBarricadeLayout()
        barricadeNode?.alpha = barricadeCurrentHP > 0 ? 1 : 0
    }

    private func updateBarricadeLayout() {
        guard let barricadeNode else { return }
        barricadeNode.position = SceneLayout.barricadePoint(in: size)
        let baseScale = max(0.7, size.height / 900.0)
        barricadeNode.setScale(baseScale)
    }

    private func hasAliveBarricade() -> Bool {
        barricadeEnabled && barricadeCurrentHP > 0 && barricadeNode?.parent != nil
    }

    private func applyDamageToBarricade(_ damage: Double) {
        guard hasAliveBarricade() else { return }
        barricadeCurrentHP -= max(0, damage)
        guard barricadeCurrentHP <= 0 else { return }
        barricadeCurrentHP = 0
        guard let node = barricadeNode else { return }
        // Обнуляємо посилання одразу: вузол ще зникає анімацією, але наступний `ensureBarricadeExists` має створити новий спрайт.
        barricadeNode = nil
        node.run(.sequence([.fadeOut(withDuration: 0.2), .removeFromParent()]))
    }

    private func heroSlot(for hero: SKNode & HeroUnitNode) -> Int? {
        heroBySlot.first { $0.value === hero }?.key
    }

    /// Результат вхідної шкоди по герою: зняті HP і урон після святого щита (до броні героя).
    typealias HeroIncomingDamageResult = (hpLost: Double, damageAfterHolyShield: Double)

    /// Спочатку знімається святий щит (слот), потім звичайний `applyDamage`.
    @discardableResult
    func applyIncomingDamageToHero(_ hero: SKNode & HeroUnitNode, rawDamage: Double) -> HeroIncomingDamageResult {
        var incoming = max(0, rawDamage)
        if let slot = heroSlot(for: hero), let sh = holyShieldBySlot[slot], sh > 0 {
            let absorb = min(sh, incoming)
            holyShieldBySlot[slot] = sh - absorb
            incoming -= absorb
        }
        let afterShield = incoming
        guard afterShield > 0, hero.isAlive else { return (0, afterShield) }
        let hpBefore = hero.currentHP
        _ = hero.applyDamage(afterShield)
        let lost = max(0, hpBefore - hero.currentHP)
        return (lost, afterShield)
    }

    /// Thorns: відсоток від удару, що **пройшов святий щит** (шкода по «тілу» героя до DR), щоб важка броня не робила відбиття невидимим.
    private func applyThornsReflect(attacker: BaseEnemyNode, defender: SKNode & HeroUnitNode, damageAfterHolyShield: Double) {
        guard attacker.isAlive, damageAfterHolyShield > 0 else { return }
        let p = max(0, defender.unitModel.stats.thornsPercentage)
        guard p > 0 else { return }
        let reflected = damageAfterHolyShield * p
        guard reflected > 0 else { return }
        if attacker.applyDamage(reflected) {
            grantEnemyDeathReward(attacker, to: defender)
        }
    }

    /// Передній ряд слотів 0…2: щит = max HP союзника × найкращий відсоток від жреців.
    private func refreshHolyShieldsForWaveStart() {
        for i in 0..<SceneLayout.heroSlotCount {
            holyShieldBySlot[i] = 0
            holyShieldMaxBySlot[i] = 0
        }
        var bestPercent: Double = 0
        for (_, h) in heroBySlot where h.isAlive {
            guard h.unitModel.role == .priest else { continue }
            let p = h.unitModel.stats.priestHolyShieldPercent
            if p > 0 { bestPercent = max(bestPercent, p) }
        }
        guard bestPercent > 0 else { return }
        for front in 0..<3 {
            guard let ally = heroBySlot[front], ally.isAlive else { continue }
            if ally.unitModel.role == .priest { continue }
            let amt = ally.unitModel.stats.baseHP * bestPercent
            holyShieldBySlot[front] = amt
            holyShieldMaxBySlot[front] = amt
        }
    }

    private func updateHolyShieldPresentations() {
        guard size.height > 1 else { return }
        let displayScale = SceneLayout.heroDisplayScale(for: size.height, logicalFrame: 100)
        var seenSlots: Set<Int> = []

        for (slot, hero) in heroBySlot {
            seenSlots.insert(slot)
            let cur = holyShieldBySlot[slot] ?? 0
            let maxSh = holyShieldMaxBySlot[slot] ?? 0
            let shouldShow = hero.isAlive && cur > 0 && maxSh > 0

            if !shouldShow {
                if let v = holyShieldVisualBySlot.removeValue(forKey: slot) {
                    v.removeFromParent()
                }
                continue
            }

            let visual: HolyShieldHeroVisual
            if let existing = holyShieldVisualBySlot[slot] {
                visual = existing
            } else {
                let v = HolyShieldHeroVisual()
                hero.addChild(v)
                holyShieldVisualBySlot[slot] = v
                visual = v
            }
            visual.updatePresentation(currentShield: cur, maxShield: maxSh, displayScale: displayScale)
        }

        for slot in Array(holyShieldVisualBySlot.keys) where !seenSlots.contains(slot) || heroBySlot[slot] == nil {
            holyShieldVisualBySlot.removeValue(forKey: slot)?.removeFromParent()
        }
    }

    /// Для пасивок жреця (хіл союзників).
    func forEachAllyHero(_ body: (SKNode & HeroUnitNode) -> Void) {
        for (_, h) in heroBySlot where h.isAlive {
            body(h)
        }
    }

    /// Стальові копита лансерів: найсильніший відсоток slow накладається на усіх ворогів під час хвилі.
    private func applySteelHoovesSlowIfNeeded() {
        guard isWaveRunning else { return }
        var maxSlow = 0.0
        for h in heroBySlot.values where h.isAlive && h.unitModel.role == .lancer {
            maxSlow = max(maxSlow, h.unitModel.stats.lancerGlobalSlowPercent)
        }
        guard maxSlow > 0 else { return }
        let p = min(0.85, maxSlow)
        for enemy in enemies where enemy.isAlive {
            enemy.applySlow(percent: p, duration: 0.4)
        }
    }

    private func spawnEnemy() {
        guard size.width > 1, size.height > 1 else { return }
        if BossKind.forWaveNumber(waveNumber) != nil {
            spawnBossEnemy()
            return
        }
        let role: EnemyType = GameSceneManager.shared.getEnemyTypes(for: waveNumber).shuffled().first ?? .slime
        let scaled = EnemyStatScaling.stats(for: role, wave: waveNumber)
        let model = EnemyUnitModel(role: role, stats: scaled)
        let enemy: BaseEnemyNode = role.createNode(model: model)
        enemy.updateScale(forSceneHeight: size.height)
        enemy.zPosition = 20

        let spread = size.width * 0.42
        enemy.position = CGPoint(
            x: CGFloat.random(in: -spread...spread),
            y: SceneLayout.enemySpawnY(for: size) + CGFloat.random(in: -20...20)
        )

        addChild(enemy)
        enemies.append(enemy)
    }

    private func spawnBossEnemy() {
        guard let kind = BossKind.forWaveNumber(waveNumber) else { return }
        let stats = EnemyStatScaling.stats(for: kind.enemyType, wave: waveNumber)
        let model = EnemyUnitModel(role: kind.enemyType, stats: stats)
        let boss: BaseEnemyNode = {
            if kind == .void { return FinaleBossNode(model: model) }
            return kind.makeMeleeBoss(model: model)
        }()
        boss.updateScale(forSceneHeight: size.height)
        boss.zPosition = 26

        let spread = size.width * 0.2
        boss.position = CGPoint(
            x: CGFloat.random(in: -spread...spread),
            y: SceneLayout.enemySpawnY(for: size) + CGFloat.random(in: -16...16)
        )

        addChild(boss)
        enemies.append(boss)
    }

    private func pushBossHPToHUD() {
        if let boss = enemies.first(where: {
            $0.isAlive && ($0 is MeleeBossNode || $0 is FinaleBossNode)
        }) {
            hudDelegate?.gameScene(
                self,
                reportedBossHP: boss.currentHP,
                totalBossHP: max(1, boss.unitModel.stats.baseHP)
            )
        } else {
            hudDelegate?.gameScene(self, reportedBossHP: 0, totalBossHP: 0)
        }
    }

    func addCoins(_ amount: Int) {
        guard amount > 0 else { return }
        let scaled = Int((Double(amount) * coinRewardMultiplier).rounded())
        hudDelegate?.gameScene(self, reportedCoinGain: max(1, scaled))
    }

    private func grantEnemyDeathReward(_ enemy: BaseEnemyNode, to hero: SKNode & HeroUnitNode) {
        let reward = enemy.unitModel.stats.reward
        let origin = CGPoint(x: enemy.position.x, y: enemy.position.y + 10)
        CoinPickupNode.spawn(in: self, from: origin, to: hero.position) { [weak self] in
            self?.addCoins(reward)
        }
    }

    /// Живі вороги для бойової логіки героїв (наприклад, сплеш навколо головної цілі).
    func livingEnemiesForHeroCombat() -> [BaseEnemyNode] {
        enemies.filter(\.isAlive)
    }

    private func livingHeroes() -> [SKNode & HeroUnitNode] {
        heroBySlot.values.filter(\.isAlive)
    }

    private func nearestLivingHero(to point: CGPoint) -> (SKNode & HeroUnitNode)? {
        let living = livingHeroes()
        guard !living.isEmpty else { return nil }
        return living.min {
            hypot($0.position.x - point.x, $0.position.y - point.y)
                < hypot($1.position.x - point.x, $1.position.y - point.y)
        }
    }

    private func spreadApproachPoint(for enemy: BaseEnemyNode, around target: CGPoint) -> CGPoint {
        let seed = enemy.unitModel.id.uuidString.unicodeScalars.reduce(0) { acc, scalar in
            (acc &* 31) &+ Int(scalar.value)
        }
        let normalized = Double(abs(seed % 1000)) / 999.0
        let xOffset = CGFloat((normalized * 2.0 - 1.0) * 40.0)
        return CGPoint(x: target.x + xOffset, y: target.y)
    }

    private func pushHeroPanelToHUD() {
        guard let slot = hudStatsSlot, let hero = heroBySlot[slot] else { return }
        let reach = hero.combatRange * SceneLayout.combatReachMultiplier(for: size.height)
        hudDelegate?.gameScene(
            self,
            reportedHeroPanelData: hero.currentHP,
            maxHP: max(1, hero.unitModel.stats.baseHP),
            attackRange: reach,
            enemyTargetCount: hero.unitModel.stats.enemyTarget
        )
    }

    private func pushWaveEnemyProgress() {
        guard isWaveRunning, waveTotalEnemies > 0 else {
            hudDelegate?.gameScene(self, reportedWaveEnemyProgress: 0, total: 0)
            return
        }
        let alive = enemies.filter { $0.isAlive }.count
        let remaining = waveEnemiesLeftToSpawn + alive
        hudDelegate?.gameScene(self, reportedWaveEnemyProgress: remaining, total: waveTotalEnemies)
    }

    override func update(_ currentTime: TimeInterval) {
        let dt: TimeInterval
        if lastUpdateTime == 0 {
            dt = 1.0 / 60.0
        } else {
            dt = min(1.0 / 20.0, currentTime - lastUpdateTime)
        }
        lastUpdateTime = currentTime

        for hero in heroBySlot.values {
            hero.updateTick(deltaTime: dt)
        }

        if isWaveRunning {
            spawnCooldown -= dt
            if waveEnemiesLeftToSpawn > 0 && spawnCooldown <= 0 {
                spawnEnemy()
                waveEnemiesLeftToSpawn -= 1
                spawnsCompletedThisWave += 1
                if waveEnemiesLeftToSpawn > 0 {
                    spawnCooldown = GameBalanceConfig.spawnIntervalAfter(spawnsAlreadyDone: spawnsCompletedThisWave)
                }
            } else if waveEnemiesLeftToSpawn == 0 && enemies.allSatisfy({ !$0.isAlive }) {
                finishWave()
            }
        }

        let reachMult = SceneLayout.combatReachMultiplier(for: size.height)

        applySteelHoovesSlowIfNeeded()

        for enemy in enemies {
            enemy.updateTick(deltaTime: dt)
            if !enemy.isAlive { continue }

            let barricadeAlive = hasAliveBarricade()
            let barricadePos = barricadeNode?.position ?? .zero

            if let meleeBoss = enemy as? MeleeBossNode {
                let boss = meleeBoss
                if barricadeAlive {
                    let dist = hypot(boss.position.x - barricadePos.x, boss.position.y - barricadePos.y)
                    let inRange = dist <= (boss.combatRange * reachMult)
                    if boss.tryAttack(whenInRange: inRange) {
                        applyDamageToBarricade(boss.damagePerHit)
                    } else if !inRange {
                        boss.moveTowards(barricadePos, deltaTime: dt)
                    }
                    continue
                }
                let targetHero = nearestLivingHero(to: boss.position)
                boss.tickMeleeBossPattern(
                    deltaTime: dt,
                    sceneSize: size,
                    nearestHero: targetHero,
                    reachMult: reachMult,
                    applyMeleeHit: { [weak self] hero, damage in
                        guard let self else { return }
                        let incoming = self.applyIncomingDamageToHero(hero, rawDamage: damage)
                        self.applyThornsReflect(attacker: boss, defender: hero, damageAfterHolyShield: incoming.damageAfterHolyShield)
                    }
                )
                continue
            }

            if let finaleBoss = enemy as? FinaleBossNode {
                let boss = finaleBoss
                if barricadeAlive {
                    let dist = hypot(boss.position.x - barricadePos.x, boss.position.y - barricadePos.y)
                    let inRange = dist <= (boss.combatRange * reachMult)
                    if boss.tryAttack(whenInRange: inRange) {
                        applyDamageToBarricade(boss.damagePerHit)
                    } else if !inRange {
                        boss.moveTowards(barricadePos, deltaTime: dt)
                    }
                    continue
                }
                let targetHero = nearestLivingHero(to: boss.position)
                boss.tickFinaleBossPattern(
                    deltaTime: dt,
                    scene: self,
                    sceneSize: size,
                    nearestHero: targetHero,
                    reachMult: reachMult,
                    livingHeroesProvider: { [weak self] in
                        guard let self else { return [] }
                        return self.livingHeroes()
                    },
                    applyMeleeHit: { [weak self] hero, damage in
                        guard let self else { return }
                        let incoming = self.applyIncomingDamageToHero(hero, rawDamage: damage)
                        self.applyThornsReflect(attacker: boss, defender: hero, damageAfterHolyShield: incoming.damageAfterHolyShield)
                    },
                    applyAOEToAllHeroes: { [weak self] damage in
                        guard let self else { return }
                        for hero in self.livingHeroes() {
                            let incoming = self.applyIncomingDamageToHero(hero, rawDamage: damage)
                            self.applyThornsReflect(attacker: boss, defender: hero, damageAfterHolyShield: incoming.damageAfterHolyShield)
                        }
                    }
                )
                continue
            }

            if barricadeAlive {
                let dist = hypot(enemy.position.x - barricadePos.x, enemy.position.y - barricadePos.y)
                let enemyInRange = dist <= (enemy.combatRange * reachMult)
                if enemy.tryAttack(whenInRange: enemyInRange) {
                    applyDamageToBarricade(enemy.damagePerHit)
                } else if !enemyInRange {
                    enemy.moveTowards(barricadePos, deltaTime: dt)
                }
                continue
            }

            guard let targetHero = nearestLivingHero(to: enemy.position) else { continue }
            let approachPoint = spreadApproachPoint(for: enemy, around: targetHero.position)

            let dist = hypot(enemy.position.x - approachPoint.x, enemy.position.y - approachPoint.y)
            let enemyInRange = dist <= (enemy.combatRange * reachMult)
            if enemy.tryAttack(whenInRange: enemyInRange) {
                let incoming = applyIncomingDamageToHero(targetHero, rawDamage: enemy.damagePerHit)
                applyThornsReflect(attacker: enemy, defender: targetHero, damageAfterHolyShield: incoming.damageAfterHolyShield)
            } else if !enemyInRange {
                enemy.moveTowards(approachPoint, deltaTime: dt)
            }
        }

        let aliveEnemies = enemies.filter { $0.isAlive }

        var anyHeroAlive = false
        for hero in heroBySlot.values where hero.isAlive {
            anyHeroAlive = true
            let heroReach = hero.combatRange * reachMult
            let inMeleeRange = aliveEnemies
                .filter { hypot($0.position.x - hero.position.x, $0.position.y - hero.position.y) <= heroReach }
                .sorted { a, b in
                    let da = hypot(a.position.x - hero.position.x, a.position.y - hero.position.y)
                    let db = hypot(b.position.x - hero.position.x, b.position.y - hero.position.y)
                    return da < db
                }
            let maxTargets = hero.maxEnemyTargets
            let targets: [BaseEnemyNode]
            if hero.unitModel.role == .priest {
                targets = inMeleeRange
            } else {
                targets = Array(inMeleeRange.prefix(maxTargets))
            }
            hero.attack(with: targets, in: self)
        }

        if !anyHeroAlive, !heroBySlot.isEmpty {
            handleAllHeroesDead()
        }

        var toRemove: [BaseEnemyNode] = []
        for enemy in enemies where !enemy.isAlive {
            toRemove.append(enemy)
        }
        enemies.removeAll(where: { !$0.isAlive })
        for enemy in toRemove {
            enemy.run(.sequence([.wait(forDuration: 0.35), .removeFromParent()]))
        }

        updateHolyShieldPresentations()

        pushHeroPanelToHUD()
        pushWaveEnemyProgress()
        pushBossHPToHUD()
    }

    private func handleAllHeroesDead() {
        isWaveRunning = false
        canStartWave = false
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.hudDelegate?.gameScene(self, reportedWaveState: self.waveNumber, canStartWave: self.canStartWave, isWaveRunning: self.isWaveRunning)
            if let vm = self.hudDelegate as? MainGameSceneViewModel {
                vm.presentLoseScreen()
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        guard !isWaveRunning else { return }

        if let slot = draggingSlot, let hero = heroBySlot[slot] {
            hero.position = loc
            for i in 0..<SceneLayout.heroSlotCount {
                let bounds = SceneLayout.heroSlotBounds(slotIndex: i, in: size)
                if bounds.contains(loc) {
                    setHighlightedSlot(i)
                    return
                }
            }
            setHighlightedSlot(nil)
            return
        }

        if pendingDragSlot != nil {
            let d = hypot(loc.x - touchBeganLocation.x, loc.y - touchBeganLocation.y)
            if d > Self.longPressMovementCancelDistance {
                cancelHeroLongPress()
            }
        }
    }

    private func finishWave() {
        isWaveRunning = false
        let completedWave = waveNumber
        waveNumber += 1
        waveTotalEnemies = 0

        // Після завершення хвилі всі герої відновлюють HP.
        for hero in heroBySlot.values {
            hero.applyModel(hero.unitModel, healToFull: true)
        }

        if barricadeEnabled {
            ensureBarricadeExists(restoreHP: true)
        }

        canStartWave = true

        // Оновлення SwiftUI / @MainActor ViewModel мають йти з головної черги.
        let completed = completedWave
        let pushHUD = { [weak self] in
            guard let self else { return }
            self.hudDelegate?.gameScene(self, didFinishWave: completed)
            self.pushWaveStateToHUD()
            self.pushWaveEnemyProgress()
            self.refreshSlotFramesVisibility()
            self.pushHeroPanelToHUD()
            self.refreshPanelAttackRangeOverlay()
        }
        if Thread.isMainThread {
            pushHUD()
        } else {
            DispatchQueue.main.async(execute: pushHUD)
        }
    }

    private func pushWaveStateToHUD() {
        hudDelegate?.gameScene(
            self,
            reportedWaveState: waveNumber,
            canStartWave: canStartWave,
            isWaveRunning: isWaveRunning
        )
    }

    private func cancelHeroLongPress() {
        longPressWorkItem?.cancel()
        longPressWorkItem = nil
        pendingDragSlot = nil
    }

    private func beginHeroDrag(slot: Int) {
        guard draggingSlot == nil else { return }
        guard !isWaveRunning else { return }
        guard let hero = heroBySlot[slot] else { return }
        pendingDragSlot = nil
        longPressWorkItem = nil
        draggingSlot = slot
        slotDragDropMode = true
        refreshSlotHighlights()
        hero.zPosition += 40
        hero.removeAction(forKey: "dragLift")
        let base = hero.xScale
        let up = SKAction.scale(to: base * 1.12, duration: 0.085)
        up.timingMode = .easeOut
        let down = SKAction.scale(to: base, duration: 0.11)
        down.timingMode = .easeIn
        hero.run(SKAction.sequence([up, down]), withKey: "dragLift")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        cancelHeroLongPress()
        touchBeganLocation = loc

        for slot in 0..<SceneLayout.heroSlotCount {
            let bounds = SceneLayout.heroSlotBounds(slotIndex: slot, in: size)
            guard bounds.contains(loc) else { continue }
            if heroBySlot[slot] != nil, !isWaveRunning {
                pendingDragSlot = slot
                let capturedSlot = slot
                let work = DispatchWorkItem { [weak self] in
                    guard let self else { return }
                    guard self.pendingDragSlot == capturedSlot else { return }
                    self.beginHeroDrag(slot: capturedSlot)
                }
                longPressWorkItem = work
                DispatchQueue.main.asyncAfter(deadline: .now() + Self.heroDragLongPressDuration, execute: work)
            }
            break
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)

        cancelHeroLongPress()

        if let from = draggingSlot {
            if let hero = heroBySlot[from] {
                hero.removeAction(forKey: "dragLift")
                hero.setScale(1)
                hero.zPosition = max(hero.zPosition - 40, 30)
            }
            defer {
                draggingSlot = nil
                slotDragDropMode = false
                setHighlightedSlot(nil)
            }
            guard !isWaveRunning else {
                layoutHeroesAndFrames()
                return
            }
            var targetSlot: Int?
            for slot in 0..<SceneLayout.heroSlotCount {
                let bounds = SceneLayout.heroSlotBounds(slotIndex: slot, in: size)
                if bounds.contains(loc) {
                    targetSlot = slot
                    break
                }
            }
            if let to = targetSlot {
                hudDelegate?.gameScene(self, didMoveHeroFrom: from, to: to)
            } else {
                layoutHeroesAndFrames()
            }
            return
        }

        // Короткий тап по слоту / поза слотами (вибір героя, HUD).
        for slot in 0..<SceneLayout.heroSlotCount {
            let bounds = SceneLayout.heroSlotBounds(slotIndex: slot, in: size)
            guard bounds.contains(loc) else { continue }
            let occupied = heroBySlot[slot] != nil
            hudDelegate?.gameScene(self, reportedSlotTap: slot, isOccupied: occupied)
            return
        }
        if let vm = hudDelegate as? MainGameSceneViewModel {
            vm.showHeroPanel = false
            vm.panelSlot = nil
            setHUDStatsSlot(nil)
            setHighlightedSlot(nil)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        cancelHeroLongPress()
        if let from = draggingSlot {
            heroBySlot[from]?.removeAction(forKey: "dragLift")
            heroBySlot[from]?.setScale(1)
            heroBySlot[from]?.zPosition = max((heroBySlot[from]?.zPosition ?? 30) - 40, 30)
            draggingSlot = nil
            slotDragDropMode = false
            setHighlightedSlot(nil)
            layoutHeroesAndFrames()
        }
    }
}
