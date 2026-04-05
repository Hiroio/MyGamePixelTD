//
//  MageHeroNode.swift
//  PixelHeroDefenseTD
//
//  Базова атака — ланцюгова блискавка (візуал + bounceCount зі статів).
//  Пізніше можна винести стиль атаки в окремий тип/перки.

import SpriteKit

final class MageHeroNode: SKNode, HeroUnitNode {
    private let sprite = SKSpriteNode()
    private let hpBar = HealthBarNode(fillColor: .green)
    private let logicalFrame: CGFloat = 100

    private var idleTextures: [SKTexture] = []
    private var attackTextures: [SKTexture] = []
    private var deathTextures: [SKTexture] = []
    private var fireProjectileTextures: [SKTexture] = []
    private var frostProjectileTextures: [SKTexture] = []

    private(set) var unitModel: HeroUnitModel
    private(set) var currentHP: Double
    private var attackCooldown: TimeInterval = 0
    private(set) var isDead = false

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
    var damagePerHit: Double { unitModel.stats.baseDamage }
    var maxEnemyTargets: Int { max(1, unitModel.stats.enemyTarget) }

    private func resolveOutgoingDamage(base: Double) -> Double {
        let critChance = max(0, unitModel.stats.critChance)
        guard critChance > 0 else { return base }
        return Double.random(in: 0...1) <= critChance ? base * 2.0 : base
    }

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

    func attack(with targets: [BaseEnemyNode], in scene: GameScene) {
        guard isAlive, !targets.isEmpty, attackCooldown <= 0 else { return }
        attackCooldown = 1.0 / max(0.2, unitModel.stats.attackSpeed)

        let primary = targets[0]
        let heroHand = CGPoint(x: position.x, y: position.y + 8)
        let attackType = unitModel.stats.mageType ?? .lightning

        playAttackAnimationThenIdle()

        let delay = SKAction.wait(forDuration: 0.14)
        let strike = SKAction.run { [weak self, weak scene, weak primary] in
            guard let self, let scene, let primary, primary.isAlive else { return }
            switch attackType {
            case .lightning:
                self.performChainLightning(from: heroHand, startingAt: primary, in: scene)
            case .fire:
                self.castOrbProjectile(
                    from: heroHand,
                    to: primary,
                    textures: self.fireProjectileTextures,
                    in: scene,
                    isFrost: false
                )
            case .frost:
                self.castOrbProjectile(
                    from: heroHand,
                    to: primary,
                    textures: self.frostProjectileTextures,
                    in: scene,
                    isFrost: true
                )
            }
        }
        run(SKAction.sequence([delay, strike]))
    }

    // MARK: - Chain lightning

    private func performChainLightning(from origin: CGPoint, startingAt target: BaseEnemyNode, in scene: GameScene) {
        var visited = Set<ObjectIdentifier>()
        var currentPos = origin
        var currentEnemy = target
        var hops = 0
        let maxHops = 1 + max(0, unitModel.stats.bounceCount)
        let knockback = unitModel.stats.knockback

        while hops < maxHops, currentEnemy.isAlive {
            let aimPoint = CGPoint(x: currentEnemy.position.x, y: currentEnemy.position.y + 6)
            spawnLightningBolt(from: currentPos, to: aimPoint, in: scene)

            let mult = pow(0.58, Double(hops))
            let dmg = resolveOutgoingDamage(base: damagePerHit * mult)

            if !visited.contains(ObjectIdentifier(currentEnemy)) {
                visited.insert(ObjectIdentifier(currentEnemy))
                if currentEnemy.applyDamage(dmg) {
                    grantCoinReward(for: currentEnemy, in: scene, from: position)
                }
                currentEnemy.applyKnockback(from: position, strength: knockback)
            }

            hops += 1
            if hops >= maxHops { break }

            guard let next = nearestUnvisitedEnemy(from: currentEnemy.position, excluding: visited, in: scene) else {
                break
            }
            currentPos = aimPoint
            currentEnemy = next
        }
    }

    private func castOrbProjectile(
        from start: CGPoint,
        to target: BaseEnemyNode,
        textures: [SKTexture],
        in scene: GameScene,
        isFrost: Bool
    ) {
        let projectile = SKSpriteNode(texture: textures.first)
        projectile.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        projectile.position = start
        projectile.zPosition = 60
        let projScale = max(0.20, sprite.xScale * 0.55) * 1.7
        projectile.setScale(projScale)
        scene.addChild(projectile)

        if !textures.isEmpty {
            let anim = SKAction.animate(with: textures, timePerFrame: 0.05, resize: true, restore: true)
            projectile.run(SKAction.repeatForever(anim), withKey: "mageProjectileAnim")
        }

        let endPoint = CGPoint(x: target.position.x, y: target.position.y + 8)
        let distance = hypot(endPoint.x - start.x, endPoint.y - start.y)
        let speed: CGFloat = 520
        let duration = TimeInterval(max(0.10, min(0.45, distance / speed)))
        let move = SKAction.move(to: endPoint, duration: duration)
        move.timingMode = .easeInEaseOut

        let impact = SKAction.run { [weak self, weak scene, weak target] in
            guard let self, let scene else { return }
            // Фікс "втечі" від AoE: урон застосовуємо миттєво по актуальній позиції цілі.
            let liveCenter: CGPoint
            if let target, target.isAlive {
                liveCenter = target.position
            } else {
                liveCenter = projectile.position
            }
            self.applyOrbImpact(at: liveCenter, in: scene, isFrost: isFrost, textures: textures)
        }
        projectile.run(.sequence([move, impact, .removeFromParent()]))
    }

    private func applyOrbImpact(at center: CGPoint, in scene: GameScene, isFrost: Bool, textures: [SKTexture]) {
        let radiusLogical = max(10, unitModel.stats.splashRadius)
        let reachMult = scene.size.height > 1 ? SceneLayout.combatReachMultiplier(for: scene.size.height) : 1
        let splashRadius = CGFloat(radiusLogical) * reachMult

        spawnOrbImpactSprite(at: center, radius: splashRadius, in: scene, textures: textures)

        let knockback = unitModel.stats.knockback
        let slow = max(0, unitModel.stats.slownessEffect)
        for enemy in scene.livingEnemiesForHeroCombat() {
            let dist = hypot(enemy.position.x - center.x, enemy.position.y - center.y)
            guard dist <= splashRadius else { continue }
            let dealt = resolveOutgoingDamage(base: damagePerHit)
            if enemy.applyDamage(dealt) {
                grantCoinReward(for: enemy, in: scene, from: position)
            }
            if knockback > 0 {
                enemy.applyKnockback(from: position, strength: knockback)
            }
            if isFrost, slow > 0 {
                enemy.applySlow(percent: slow, duration: 2.0)
            }
        }
    }

    private func spawnOrbImpactSprite(at center: CGPoint, radius: CGFloat, in scene: GameScene, textures: [SKTexture]) {
        guard let first = textures.first else { return }
        let fx = SKSpriteNode(texture: first)
        fx.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        fx.position = center
        fx.zPosition = 58
        let base = max(first.size().width, first.size().height)
        let targetDiameter = radius * 2
        let scale = base > 0 ? max(0.01, targetDiameter / base) : 1
        fx.setScale(scale)
        scene.addChild(fx)

        let anim = SKAction.animate(with: textures, timePerFrame: 0.05, resize: true, restore: false)
        fx.run(.sequence([anim, .removeFromParent()]))
    }

    private func nearestUnvisitedEnemy(from point: CGPoint, excluding visited: Set<ObjectIdentifier>, in scene: GameScene) -> BaseEnemyNode? {
        scene.livingEnemiesForHeroCombat()
            .filter { !visited.contains(ObjectIdentifier($0)) }
            .min { a, b in
                let da = hypot(a.position.x - point.x, a.position.y - point.y)
                let db = hypot(b.position.x - point.x, b.position.y - point.y)
                return da < db
            }
    }

    private func spawnLightningBolt(from start: CGPoint, to end: CGPoint, in scene: GameScene) {
        let path = Self.zigzagLightningPath(from: start, to: end)
        let bolt = SKShapeNode(path: path)
        bolt.strokeColor = SKColor(red: 0.58, green: 0.90, blue: 1.0, alpha: 0.95)
        bolt.fillColor = .clear
        bolt.lineWidth = 2.8
        bolt.glowWidth = 5
        bolt.lineCap = .round
        bolt.lineJoin = .miter
        bolt.zPosition = 58
        bolt.name = "mageLightning"
        scene.addChild(bolt)
        bolt.run(SKAction.sequence([
            .wait(forDuration: 0.1),
            SKAction.fadeOut(withDuration: 0.06),
            .removeFromParent()
        ]))
    }

    /// Два різких «злами» між початком і кінцем (4 сегменти).
    private static func zigzagLightningPath(from start: CGPoint, to end: CGPoint) -> CGPath {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let length = max(8, hypot(dx, dy))
        let dir = CGPoint(x: dx / length, y: dy / length)
        let perp = CGPoint(x: -dir.y, y: dir.x)
        let amplitude = max(10, min(42, length * 0.14))

        let p1 = CGPoint(
            x: start.x + dir.x * length * 0.32 + perp.x * amplitude,
            y: start.y + dir.y * length * 0.32 + perp.y * amplitude
        )
        let p2 = CGPoint(
            x: start.x + dir.x * length * 0.62 - perp.x * amplitude * 0.95,
            y: start.y + dir.y * length * 0.62 - perp.y * amplitude * 0.95
        )

        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: p1)
        path.addLine(to: p2)
        path.addLine(to: end)
        return path
    }

    private func grantCoinReward(for target: BaseEnemyNode, in scene: GameScene, from heroPos: CGPoint) {
        let reward = target.unitModel.stats.reward
        let origin = CGPoint(x: target.position.x, y: target.position.y + 10)
        CoinPickupNode.spawn(in: scene, from: origin, to: heroPos) { [weak scene] in
            scene?.addCoins(reward)
        }
    }

    // MARK: - Animations

    private func loadTextures() {
        idleTextures = SpriteSheet.horizontalStripTextures(imageNamed: "MageIdle", frameCount: 6)
        attackTextures = SpriteSheet.horizontalStripTextures(imageNamed: "MageAttack", frameCount: 6)
        deathTextures = SpriteSheet.horizontalStripTextures(imageNamed: "MageDeath", frameCount: 4)
        fireProjectileTextures = SpriteSheet.horizontalStripTextures(imageNamed: "MageFireProjectile", frameCount: 7)
        frostProjectileTextures = SpriteSheet.horizontalStripTextures(imageNamed: "MageFrostProjectile", frameCount: 7)
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
        let animate = SKAction.animate(with: attackTextures, timePerFrame: 0.08, resize: true, restore: true)
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
}
