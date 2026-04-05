//
//  ArcherHeroNode.swift
//  PixelHeroDefenseTD
//

import SpriteKit

final class ArcherHeroNode: SKNode, HeroUnitNode {
    private let sprite = SKSpriteNode()
    private let hpBar = HealthBarNode(fillColor: .green)
    private let logicalFrame: CGFloat = 100

    private var idleTextures: [SKTexture] = []
    private var attackTextures: [SKTexture] = []
    private var deathTextures: [SKTexture] = []

    private let projectileTexture: SKTexture

    private(set) var unitModel: HeroUnitModel
    private(set) var currentHP: Double
    private var attackCooldown: TimeInterval = 0
    private(set) var isDead = false

    init(model: HeroUnitModel) {
        self.unitModel = model
        self.currentHP = model.stats.baseHP

        let projectile = SKTexture(imageNamed: "ArcherProjectile")
        projectile.filteringMode = .nearest
        self.projectileTexture = projectile

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
    var damagePerHit: Double { unitModel.stats.baseDamage }
    var maxEnemyTargets: Int { max(1, unitModel.stats.enemyTarget) }

    private func resolveOutgoingDamage(base: Double) -> Double {
        let critChance = max(0, unitModel.stats.critChance)
        guard critChance > 0 else { return base }
        return Double.random(in: 0...1) <= critChance ? base * 2.0 : base
    }

    // MARK: - HUD overlay

    private var panelAttackRangeShape: SKShapeNode?

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

    // MARK: - Model sync

    func updateScale(forSceneHeight height: CGFloat) {
        let s = SceneLayout.heroDisplayScale(for: height, logicalFrame: logicalFrame)
        sprite.setScale(s)
        hpBar.setScale(max(0.85, s))
    }

    func updateTick(deltaTime: TimeInterval) {
        attackCooldown = max(0, attackCooldown - deltaTime)
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

    // MARK: - Combat (melee/range)

    @discardableResult
    func applyDamage(_ value: Double) -> Bool {
        guard isAlive else { return false }
        currentHP -= value
        updateHPBar()
        if currentHP <= 0 {
            isDead = true
            playDeath()
            return true
        }
        return false
    }

    func playUpgradeFeedback() {
        // Поки апгрейди не додані в логіку, лишаємо тільки візуальний нудж.
        removeAction(forKey: "upgradeNudge")
        let up = SKAction.moveBy(x: 0, y: 18, duration: 0.12)
        up.timingMode = .easeOut
        let down = SKAction.moveBy(x: 0, y: -18, duration: 0.14)
        down.timingMode = .easeIn
        run(SKAction.sequence([up, down]), withKey: "upgradeNudge")
    }

    func attack(with targets: [BaseEnemyNode], in scene: GameScene) {
        guard isAlive, !targets.isEmpty, attackCooldown <= 0 else { return }
        attackCooldown = 1.0 / max(0.2, unitModel.stats.attackSpeed)
        let heroPos = position
        let primaryTargets = Array(targets.prefix(maxEnemyTargets))
        if primaryTargets.isEmpty { return }

        playAttackAnimationThenIdle()
        for (index, target) in primaryTargets.enumerated() {
            let launchDelay = SKAction.wait(forDuration: 0.03 * Double(index))
            let shoot = SKAction.run { [weak self, weak scene, weak target] in
                guard let self, let scene, let target else { return }
                self.fireArrow(from: heroPos, to: target, in: scene)
            }
            run(.sequence([launchDelay, shoot]))
        }
    }

    private func fireArrow(from heroPos: CGPoint, to target: BaseEnemyNode, in scene: GameScene) {
        let projectile = SKSpriteNode(texture: projectileTexture)
        projectile.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        projectile.position = heroPos
        projectile.zPosition = 60
        let projScale = max(0.20, sprite.xScale * 0.55) * 1.8
        projectile.setScale(projScale)
        scene.addChild(projectile)

        let endPoint = CGPoint(x: target.position.x, y: target.position.y + 6)
        let distance = hypot(endPoint.x - heroPos.x, endPoint.y - heroPos.y)
        let speed: CGFloat = 650
        let duration = TimeInterval(max(0.08, min(0.35, distance / speed)))
        let move = SKAction.move(to: endPoint, duration: duration)
        move.timingMode = .easeInEaseOut

        let hit = SKAction.run { [weak self, weak scene, weak target] in
            guard let self, let scene, let target else { return }
            self.applyArrowHit(on: target, in: scene, heroPos: heroPos)
        }
        projectile.run(.sequence([move, hit, .removeFromParent()]))
    }

    private func applyArrowHit(on target: BaseEnemyNode, in scene: GameScene, heroPos: CGPoint) {
        guard target.isAlive else { return }

        let distanceFromHero = hypot(target.position.x - heroPos.x, target.position.y - heroPos.y)
        let focusBonus = distanceFromHero > 50 ? unitModel.stats.focusDistanceBonus : 0
        let primaryDamage = resolveOutgoingDamage(base: damagePerHit * (1.0 + max(0, focusBonus)))

        if target.applyDamage(primaryDamage) {
            grantCoinReward(for: target, in: scene, heroPos: heroPos)
        }
        target.applyKnockback(from: heroPos, strength: unitModel.stats.knockback)
        if unitModel.stats.slownessEffect > 0 {
            target.applySlow(percent: unitModel.stats.slownessEffect, duration: 2.0)
        }

        let bounceCount = max(0, unitModel.stats.bounceCount)
        guard bounceCount > 0 else { return }

        let bounceTargets = scene
            .livingEnemiesForHeroCombat()
            .filter { $0 !== target }
            .sorted { a, b in
                let da = hypot(a.position.x - target.position.x, a.position.y - target.position.y)
                let db = hypot(b.position.x - target.position.x, b.position.y - target.position.y)
                return da < db
            }
            .prefix(bounceCount)

        let bounceDamage = primaryDamage * 0.5
        for bounce in bounceTargets {
            if bounce.applyDamage(bounceDamage) {
                grantCoinReward(for: bounce, in: scene, heroPos: heroPos)
            }
            bounce.applyKnockback(from: target.position, strength: unitModel.stats.knockback)
            if unitModel.stats.slownessEffect > 0 {
                bounce.applySlow(percent: unitModel.stats.slownessEffect, duration: 2.0)
            }
        }
    }

    private func grantCoinReward(for target: BaseEnemyNode, in scene: GameScene, heroPos: CGPoint) {
        let reward = target.unitModel.stats.reward
        let origin = CGPoint(x: target.position.x, y: target.position.y + 10)
        CoinPickupNode.spawn(in: scene, from: origin, to: heroPos) { [weak scene] in
            scene?.addCoins(reward)
        }
    }

    // MARK: - Animations

    private func loadTextures() {
        idleTextures = SpriteSheet.horizontalStripTextures(imageNamed: "ArcherIdle", frameCount: 6)
        attackTextures = SpriteSheet.horizontalStripTextures(imageNamed: "ArcherAttack", frameCount: 9)
        deathTextures = SpriteSheet.horizontalStripTextures(imageNamed: "Archer-Death", frameCount: 4)
        if let first = idleTextures.first {
            sprite.texture = first
            sprite.size = first.size()
        }
    }

    private func runIdleLoop() {
        sprite.removeAllActions()
        guard !idleTextures.isEmpty else { return }
        let animate = SKAction.animate(with: idleTextures, timePerFrame: 0.12, resize: true, restore: true)
        sprite.run(SKAction.repeatForever(animate), withKey: "anim")
    }

    private func playAttackAnimationThenIdle() {
        sprite.removeAction(forKey: "anim")
        guard !attackTextures.isEmpty else {
            runIdleLoop()
            return
        }
        let animate = SKAction.animate(with: attackTextures, timePerFrame: 0.06, resize: true, restore: true)
        let done = SKAction.run { [weak self] in self?.runIdleLoop() }
        sprite.run(SKAction.sequence([animate, done]), withKey: "anim")
    }

    private func playDeath() {
        sprite.removeAction(forKey: "anim")
        guard !deathTextures.isEmpty else { return }
        let animate = SKAction.animate(with: deathTextures, timePerFrame: 0.10, resize: true, restore: false)
        sprite.run(SKAction.sequence([animate, .fadeOut(withDuration: 0.2)]), withKey: "anim")
    }

    private func updateHPBar() {
        let maxHP = max(1, unitModel.stats.baseHP)
        hpBar.setProgress(CGFloat(currentHP / maxHP))
    }

}

