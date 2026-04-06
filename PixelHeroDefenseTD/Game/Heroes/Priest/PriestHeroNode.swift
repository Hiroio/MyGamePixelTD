//
//  PriestHeroNode.swift
//  PixelHeroDefenseTD
//

import SpriteKit

/// Жрець: випалює HP ворогам у радіусі (повільні тики), святі землі, хіл союзників.
final class PriestHeroNode: SKNode, HeroUnitNode {
    private let sprite = SKSpriteNode()
    private let hpBar = HealthBarNode(fillColor: .green)
    private let logicalFrame: CGFloat = 100

    private var idleTextures: [SKTexture] = []
    private var attackTextures: [SKTexture] = []
    private var deathTextures: [SKTexture] = []

    private(set) var unitModel: HeroUnitModel
    private(set) var currentHP: Double
    private var attackCooldown: TimeInterval = 0
    private(set) var isDead = false
    private weak var observingScene: GameScene?
    private var mintAuraNode: SKShapeNode?
    private var panelAttackRangeShape: SKShapeNode?

    init(model: HeroUnitModel) {
        self.unitModel = model
        self.currentHP = model.stats.baseHP
        super.init()
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(sprite)
        hpBar.position = CGPoint(x: 0, y: -40)
        hpBar.zPosition = 25
        addChild(hpBar)
        loadTextures()
        runIdleLoop()
        updateHPBar()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    var isAlive: Bool { !isDead && currentHP > 0 }

    var combatRange: CGFloat { CGFloat(unitModel.stats.range) }

    /// Половина «базової шкоди» картки — фактичний випал за тик (повільний attack speed).
    var damagePerHit: Double { unitModel.stats.baseDamage * 0.5 }

    var maxEnemyTargets: Int { max(1, unitModel.stats.enemyTarget) }

    private func resolveOutgoingDamage(base: Double) -> Double {
        let critChance = max(0, unitModel.stats.critChance)
        guard critChance > 0 else { return base }
        return Double.random(in: 0...1) <= critChance ? base * 2.0 : base
    }

    func updateTick(deltaTime: TimeInterval) {
        attackCooldown = max(0, attackCooldown - deltaTime)
        guard let scene = observingScene, isAlive else { return }
        applyHolyGroundIfNeeded(in: scene)
        applyPassiveHeal(in: scene, dt: deltaTime)
        updateMintAura(in: scene)
    }

    func updateScale(forSceneHeight height: CGFloat) {
        let s = SceneLayout.heroDisplayScale(for: height, logicalFrame: logicalFrame)
        sprite.setScale(s)
        hpBar.setScale(max(0.85, s))
    }

    func applyModel(_ model: HeroUnitModel, healToFull: Bool) {
        unitModel = model
        if healToFull {
            currentHP = model.stats.baseHP
            if isDead {
                isDead = false
                sprite.alpha = 1
                runIdleLoop()
            }
        } else {
            currentHP = min(currentHP, model.stats.baseHP)
        }
        updateHPBar()
    }

    @discardableResult
    func applyDamage(_ value: Double) -> Bool {
        guard isAlive else { return false }
        let reduced = value * (1.0 - min(0.85, max(0.0, unitModel.stats.damageReduction)))
        currentHP -= max(0, reduced)
        updateHPBar()
        if currentHP <= 0 {
            isDead = true
            playDeath()
            return true
        }
        return false
    }

    func restoreHP(_ amount: Double) {
        guard isAlive, amount > 0 else { return }
        currentHP = min(unitModel.stats.baseHP, currentHP + amount)
        updateHPBar()
    }

    func playUpgradeFeedback() {
        removeAction(forKey: "upgradeNudge")
        let up = SKAction.moveBy(x: 0, y: 18, duration: 0.12)
        up.timingMode = .easeOut
        let down = SKAction.moveBy(x: 0, y: -18, duration: 0.14)
        down.timingMode = .easeIn
        run(SKAction.sequence([up, down]), withKey: "upgradeNudge")
    }

    func setPanelAttackRangeVisible(_ visible: Bool, radius: CGFloat) {
        panelAttackRangeShape?.removeFromParent()
        panelAttackRangeShape = nil
        guard visible, radius > 0 else { return }
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.strokeColor = SKColor.white.withAlphaComponent(0.55)
        circle.fillColor = SKColor.white.withAlphaComponent(0.05)
        circle.lineWidth = 1.5
        circle.zPosition = -12
        circle.isUserInteractionEnabled = false
        addChild(circle)
        panelAttackRangeShape = circle
    }

    func attack(with targets: [BaseEnemyNode], in scene: GameScene) {
        observingScene = scene
        guard isAlive else { return }
        updateMintAura(in: scene)

        let reachMult = SceneLayout.combatReachMultiplier(for: scene.size.height)
        let r = Double(combatRange * reachMult)
        let inRange = scene.livingEnemiesForHeroCombat().filter { enemy in
            hypot(Double(enemy.position.x - position.x), Double(enemy.position.y - position.y)) <= r
        }

        guard !inRange.isEmpty, attackCooldown <= 0 else { return }
        attackCooldown = 1.0 / max(0.15, unitModel.stats.attackSpeed)
        playAttackThenIdle()

        let dmg = resolveOutgoingDamage(base: damagePerHit)
        var drained: Double = 0
        for enemy in inRange {
            guard enemy.isAlive else { continue }
            let before = enemy.currentHP
            let chunk = min(dmg, before)
            if enemy.applyDamage(dmg) {
                grantCoinReward(for: enemy, scene: scene)
            }
            drained += chunk
        }
        let vamp = max(0, unitModel.stats.lifestealPercentage)
        if vamp > 0 {
            restoreHP(drained * vamp)
        }
    }

    // MARK: - Passives

    private func applyHolyGroundIfNeeded(in scene: GameScene) {
        let slow = unitModel.stats.priestHolyGroundSlow
        guard slow > 0 else { return }
        let reachMult = SceneLayout.combatReachMultiplier(for: scene.size.height)
        let r = Double(combatRange * reachMult)
        let pct = min(0.85, slow)
        for enemy in scene.livingEnemiesForHeroCombat() {
            let d = hypot(Double(enemy.position.x - position.x), Double(enemy.position.y - position.y))
            guard d <= r else { continue }
            enemy.applySlow(percent: pct, duration: 0.55)
        }
    }

    private func applyPassiveHeal(in scene: GameScene, dt: TimeInterval) {
        let rate = unitModel.stats.priestHealPerSecond
        guard rate > 0 else { return }
        let pool = rate * dt
        guard pool > 0.001 else { return }

        let reachMult = SceneLayout.combatReachMultiplier(for: scene.size.height)
        let r = Double(combatRange * reachMult)
        var best: (SKNode & HeroUnitNode)?
        var bestMissing: Double = 0

        scene.forEachAllyHero { ally in
            guard ally !== self else { return }
            let missing = ally.unitModel.stats.baseHP - ally.currentHP
            guard missing > 0.5 else { return }
            let d = hypot(Double(ally.position.x - position.x), Double(ally.position.y - position.y))
            guard d <= r else { return }
            if missing > bestMissing {
                bestMissing = missing
                best = ally
            }
        }
        guard let target = best else { return }
        let gain = min(pool, bestMissing)
        target.restoreHP(gain)
    }

    private func updateMintAura(in scene: GameScene) {
        let reachMult = SceneLayout.combatReachMultiplier(for: scene.size.height)
        let radius = CGFloat(combatRange * reachMult)
        let hasEnemy = scene.livingEnemiesForHeroCombat().contains { enemy in
            hypot(enemy.position.x - position.x, enemy.position.y - position.y) <= radius
        }
        if hasEnemy {
            if mintAuraNode == nil {
                let node = SKShapeNode()
                node.strokeColor = .clear
                node.fillColor = SKColor(red: 0.58, green: 0.98, blue: 0.82, alpha: 0.2)
                node.zPosition = -9
                node.isUserInteractionEnabled = false
                addChild(node)
                mintAuraNode = node
            }
            let rect = CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2)
            mintAuraNode?.path = CGPath(ellipseIn: rect, transform: nil)
            mintAuraNode?.isHidden = false
        } else {
            mintAuraNode?.isHidden = true
        }
    }

    // MARK: - Visuals & animation

    private func loadTextures() {
        idleTextures = SpriteSheet.horizontalStripTextures(imageNamed: "PriestIdle", frameCount: 6)
        attackTextures = SpriteSheet.horizontalStripTextures(imageNamed: "PriestHeal", frameCount: 6)
        deathTextures = SpriteSheet.horizontalStripTextures(imageNamed: "PriestDeath", frameCount: 4)
        if let first = idleTextures.first {
            sprite.texture = first
            sprite.size = first.size()
        }
    }

    private func runIdleLoop() {
        sprite.removeAction(forKey: "anim")
        guard !idleTextures.isEmpty else { return }
        let animate = SKAction.animate(with: idleTextures, timePerFrame: 0.12, resize: true, restore: true)
        sprite.run(SKAction.repeatForever(animate), withKey: "anim")
    }

    private func playAttackThenIdle() {
        sprite.removeAction(forKey: "anim")
        guard !attackTextures.isEmpty else {
            runIdleLoop()
            return
        }
        let animate = SKAction.animate(with: attackTextures, timePerFrame: 0.1, resize: true, restore: true)
        let done = SKAction.run { [weak self] in self?.runIdleLoop() }
        sprite.run(SKAction.sequence([animate, done]), withKey: "anim")
    }

    private func playDeath() {
        sprite.removeAction(forKey: "anim")
        guard !deathTextures.isEmpty else { return }
        let animate = SKAction.animate(with: deathTextures, timePerFrame: 0.12, resize: true, restore: false)
        sprite.run(SKAction.sequence([animate, .fadeOut(withDuration: 0.2)]), withKey: "anim")
    }

    private func updateHPBar() {
        let maxHP = max(1, unitModel.stats.baseHP)
        hpBar.setProgress(CGFloat(currentHP / maxHP))
    }

    private func grantCoinReward(for target: BaseEnemyNode, scene: GameScene) {
        let reward = target.unitModel.stats.reward
        let origin = CGPoint(x: target.position.x, y: target.position.y + 10)
        CoinPickupNode.spawn(in: scene, from: origin, to: position) { [weak scene] in
            scene?.addCoins(reward)
        }
    }
}
