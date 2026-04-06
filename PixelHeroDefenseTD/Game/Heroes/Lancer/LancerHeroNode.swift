//
//  LancerHeroNode.swift
//  PixelHeroDefenseTD
//

import SpriteKit

/// Ланселот: з місця випускає «копія» (анімація LancerWalk), що летить у ворога; при влучанні зникає й завдає шкоди.
final class LancerHeroNode: SKNode, HeroUnitNode {
    private let sprite = SKSpriteNode()
    private let hpBar = HealthBarNode(fillColor: .green)
    private let logicalFrame: CGFloat = 100

    private var idleTextures: [SKTexture] = []
    private var lanceFlightTextures: [SKTexture] = []
    private var deathTextures: [SKTexture] = []

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

    /// Базова шкода до крита / тарану / рикошету.
    private func resolvedStrikeDamage() -> Double {
        let base = unitModel.stats.baseDamage
        let bonus = unitModel.stats.lancerCritDamageBonus
        if bonus > 0 {
            return base * (1.0 + bonus)
        }
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
        guard isAlive, !targets.isEmpty, attackCooldown <= 0 else { return }
        attackCooldown = 1.0 / max(0.2, unitModel.stats.attackSpeed)

        let volley = Array(targets.prefix(maxEnemyTargets))
        for (index, target) in volley.enumerated() {
            let delay = SKAction.wait(forDuration: 0.07 * Double(index))
            let fire = SKAction.run { [weak self, weak scene, weak target] in
                guard let self, let scene, let target, target.isAlive else { return }
                self.spawnLanceProjectile(toward: target, in: scene)
            }
            run(SKAction.sequence([delay, fire]))
        }
    }

    // MARK: - Lance projectile

    private func spawnLanceProjectile(toward primary: BaseEnemyNode, in scene: GameScene) {
        guard primary.isAlive, !lanceFlightTextures.isEmpty else { return }
        let heroPos = position
        let reachMult = scene.size.height > 1 ? SceneLayout.combatReachMultiplier(for: scene.size.height) : 1

        let projectile = SKSpriteNode(texture: lanceFlightTextures.first)
        projectile.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        projectile.position = heroPos
        projectile.zPosition = 38
        let ps = max(0.22, sprite.xScale * 0.95)
        projectile.setScale(ps)
        scene.addChild(projectile)

        if lanceFlightTextures.count > 1 {
            let walkAnim = SKAction.animate(with: lanceFlightTextures, timePerFrame: 0.07, resize: true, restore: true)
            projectile.run(SKAction.repeatForever(walkAnim), withKey: "lanceWalk")
        }

        let endPoint = CGPoint(x: primary.position.x, y: primary.position.y + 5)
        let dist = hypot(endPoint.x - heroPos.x, endPoint.y - heroPos.y)
        let speed: CGFloat = 540
        let duration = TimeInterval(max(0.11, min(0.42, dist / speed)))
        let move = SKAction.move(to: endPoint, duration: duration)
        move.timingMode = .easeInEaseOut

        let impact = SKAction.run { [weak self, weak scene, weak primary, weak projectile] in
            projectile?.removeAllActions()
            projectile?.removeFromParent()
            guard let self, let scene, let primary, primary.isAlive else { return }
            self.onLanceImpact(primary: primary, heroPos: heroPos, in: scene, reachMult: reachMult)
        }
        projectile.run(SKAction.sequence([move, impact]))
    }

    private func onLanceImpact(primary: BaseEnemyNode, heroPos: CGPoint, in scene: GameScene, reachMult: CGFloat) {
        let stats = unitModel.stats
        let hasRam = stats.unlockedMechanics.contains(.lancerRam) && stats.splashRadius > 0
        let hasRico = stats.unlockedMechanics.contains(.lancerRicochet) && stats.bounceCount > 0

        if hasRam {
            resolveRamLine(primary: primary, heroPos: heroPos, in: scene, reachMult: reachMult)
            return
        }

        let dmg = resolvedStrikeDamage()
        applyHit(on: primary, damage: dmg, knockFrom: heroPos, in: scene)

        if hasRico {
            startRicochet(
                from: primary.position,
                excluding: [ObjectIdentifier(primary)],
                hopsLeft: stats.bounceCount,
                damage: dmg,
                in: scene
            )
        }
    }

    private func resolveRamLine(primary: BaseEnemyNode, heroPos: CGPoint, in scene: GameScene, reachMult: CGFloat) {
        let extraLogical = CGFloat(unitModel.stats.splashRadius) * reachMult
        let dir = normalizedVector(from: heroPos, to: primary.position)
        let start = primary.position
        let baseDmg = resolvedStrikeDamage()

        var hits: [(enemy: BaseEnemyNode, t: CGFloat)] = []
        for enemy in scene.livingEnemiesForHeroCombat() where enemy.isAlive {
            let (t, perp) = projectOntoRay(point: enemy.position, origin: start, dir: dir)
            guard perp < 58, t >= -18, t <= extraLogical + 35 else { continue }
            hits.append((enemy, t))
        }

        hits.sort { $0.t < $1.t }
        var ordered: [BaseEnemyNode] = []
        for h in hits {
            guard !ordered.contains(where: { $0 === h.enemy }) else { continue }
            ordered.append(h.enemy)
        }
        if let idx = ordered.firstIndex(where: { $0 === primary }), idx != 0 {
            let p = ordered.remove(at: idx)
            ordered.insert(p, at: 0)
        } else if !ordered.contains(where: { $0 === primary }) {
            ordered.insert(primary, at: 0)
        }

        for (i, enemy) in ordered.enumerated() where enemy.isAlive {
            let mult = pow(0.8, Double(i))
            let dmg = baseDmg * mult
            applyHit(on: enemy, damage: dmg, knockFrom: heroPos, in: scene)
        }
    }

    private func startRicochet(
        from point: CGPoint,
        excluding: Set<ObjectIdentifier>,
        hopsLeft: Int,
        damage: Double,
        in scene: GameScene
    ) {
        guard hopsLeft > 0 else { return }
        let candidates = scene.livingEnemiesForHeroCombat().filter { excluding.contains(ObjectIdentifier($0)) == false }
        guard let next = candidates.min(by: { a, b in
            hypot(a.position.x - point.x, a.position.y - point.y) < hypot(b.position.x - point.x, b.position.y - point.y)
        }) else { return }

        let projectile = SKSpriteNode(texture: lanceFlightTextures.first)
        projectile.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        projectile.position = point
        projectile.zPosition = 38
        projectile.setScale(max(0.22, sprite.xScale * 0.95))
        scene.addChild(projectile)

        if lanceFlightTextures.count > 1 {
            let walkAnim = SKAction.animate(with: lanceFlightTextures, timePerFrame: 0.07, resize: true, restore: true)
            projectile.run(SKAction.repeatForever(walkAnim), withKey: "lanceWalk")
        }

        let end = CGPoint(x: next.position.x, y: next.position.y + 5)
        let dist = hypot(end.x - point.x, end.y - point.y)
        let duration = TimeInterval(max(0.08, min(0.35, dist / 520)))
        let move = SKAction.move(to: end, duration: duration)
        move.timingMode = .easeInEaseOut

        var ex = excluding
        ex.insert(ObjectIdentifier(next))

        let done = SKAction.run { [weak self, weak scene, weak next, weak projectile] in
            projectile?.removeAllActions()
            projectile?.removeFromParent()
            guard let self, let scene, let next, next.isAlive else { return }
            self.applyHit(on: next, damage: damage, knockFrom: point, in: scene)
            self.startRicochet(from: next.position, excluding: ex, hopsLeft: hopsLeft - 1, damage: damage, in: scene)
        }
        projectile.run(SKAction.sequence([move, done]))
    }

    private func applyHit(on enemy: BaseEnemyNode, damage: Double, knockFrom: CGPoint, in scene: GameScene) {
        guard enemy.isAlive else { return }
        if enemy.applyDamage(damage) {
            grantCoin(for: enemy, in: scene)
        }
        enemy.applyKnockback(from: knockFrom, strength: unitModel.stats.knockback)
    }

    private func grantCoin(for target: BaseEnemyNode, in scene: GameScene) {
        let reward = target.unitModel.stats.reward
        let origin = CGPoint(x: target.position.x, y: target.position.y + 10)
        CoinPickupNode.spawn(in: scene, from: origin, to: position) { [weak scene] in
            scene?.addCoins(reward)
        }
    }

    private func loadTextures() {
        idleTextures = SpriteSheet.horizontalStripTextures(imageNamed: "LancerIdle", frameCount: 6)
        lanceFlightTextures = SpriteSheet.horizontalStripTextures(imageNamed: "LancerWalk", frameCount: 8)
        deathTextures = SpriteSheet.horizontalStripTextures(imageNamed: "LancerDeath", frameCount: 4)
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

    private func normalizedVector(from: CGPoint, to: CGPoint) -> CGVector {
        let dx = to.x - from.x
        let dy = to.y - from.y
        let len = max(0.001, hypot(dx, dy))
        return CGVector(dx: dx / len, dy: dy / len)
    }

    /// `t` — проєкція на промінь від `origin` у напрямку `dir` (одиничний); `perp` — відстань до променя.
    private func projectOntoRay(point: CGPoint, origin: CGPoint, dir: CGVector) -> (t: CGFloat, perp: CGFloat) {
        let vx = point.x - origin.x
        let vy = point.y - origin.y
        let t = vx * dir.dx + vy * dir.dy
        let px = vx - t * dir.dx
        let py = vy - t * dir.dy
        return (t, hypot(px, py))
    }
}
