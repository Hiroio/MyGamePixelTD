//
//  KnightHeroNode.swift
//  PixelHeroDefenseTD
//

import SpriteKit

final class KnightHeroNode: SKNode, HeroUnitNode {
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

    var combatRange: CGFloat {
        CGFloat(unitModel.stats.range)
    }

    var damagePerHit: Double {
        unitModel.stats.baseDamage
    }

    var maxEnemyTargets: Int {
        max(1, unitModel.stats.enemyTarget)
    }

    private func resolveOutgoingDamage(base: Double) -> Double {
        let critChance = max(0, unitModel.stats.critChance)
        guard critChance > 0 else { return base }
        return Double.random(in: 0...1) <= critChance ? base * 2.0 : base
    }

    /// Тап лише по «тілу» спрайта (для кількох героїв на екрані).
    func containsTap(at scenePoint: CGPoint) -> Bool {
        let halfW = (sprite.size.width * abs(sprite.xScale)) * 0.42
        let halfH = (sprite.size.height * abs(sprite.yScale)) * 0.42
        let dx = scenePoint.x - position.x
        let dy = scenePoint.y - position.y
        return abs(dx) <= halfW && abs(dy) <= halfH
    }

    /// Оновити стати з ViewModel (після апгрейду).
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

    /// Легкий «підкид» вгору після апгрейду.
    func playUpgradeFeedback() {
        removeAction(forKey: "upgradeNudge")
        let up = SKAction.moveBy(x: 0, y: 18, duration: 0.12)
        up.timingMode = .easeOut
        let down = SKAction.moveBy(x: 0, y: -18, duration: 0.14)
        down.timingMode = .easeIn
        run(SKAction.sequence([up, down]), withKey: "upgradeNudge")
    }

    /// Постійне коло радіусу під час відкритого HUD; не бере участі в hit-testing.
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

    private func loadTextures() {
        idleTextures = SpriteSheet.horizontalStripTextures(imageNamed: "KnightIdle", frameCount: 6)
        attackTextures = SpriteSheet.horizontalStripTextures(imageNamed: "KnightAttack", frameCount: 7)
        deathTextures = SpriteSheet.horizontalStripTextures(imageNamed: "KnightDeath", frameCount: 4)
        if let first = idleTextures.first {
            sprite.texture = first
            sprite.size = first.size()
        }
    }

    func updateScale(forSceneHeight height: CGFloat) {
        let s = SceneLayout.heroDisplayScale(for: height, logicalFrame: logicalFrame)
        sprite.setScale(s)
        hpBar.setScale(max(0.85, s))
    }

    func updateTick(deltaTime: TimeInterval) {
        attackCooldown = max(0, attackCooldown - deltaTime)
    }

    /// Одна анімація атаки, якщо є хоча б одна ціль у радіусі.
    func tryAttack(whenInRange: Bool) -> Bool {
        guard whenInRange, isAlive, attackCooldown <= 0 else { return false }
        let enrageMult = unitModel.stats.isEnragedActive > 0 ? unitModel.stats.enrageAttackSpeedMultiplier : 1.0
        let speed = max(0.2, unitModel.stats.attackSpeed * (isEnragedNow ? enrageMult : 1.0))
        attackCooldown = 1.0 / speed
        playAttackThenIdle()
        return true
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

    private func updateHPBar() {
        let maxHP = max(1, unitModel.stats.baseHP)
        hpBar.setProgress(CGFloat(currentHP / maxHP))
        updateEnrageVisual()
    }

    private var isEnragedNow: Bool {
        let threshold = unitModel.stats.isEnragedActive
        guard threshold > 0 else { return false }
        return currentHP / max(1, unitModel.stats.baseHP) <= threshold
    }

    private func updateEnrageVisual() {
        if isEnragedNow {
            sprite.colorBlendFactor = 0.32
            sprite.color = .red
        } else {
            sprite.colorBlendFactor = 0.0
            sprite.color = .white
        }
    }

    private func runIdleLoop() {
        sprite.removeAllActions()
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
        let animate = SKAction.animate(with: attackTextures, timePerFrame: 0.07, resize: true, restore: true)
        let done = SKAction.run { [weak self] in self?.runIdleLoop() }
        sprite.run(SKAction.sequence([animate, done]), withKey: "anim")
    }

    private func playDeath() {
        sprite.removeAction(forKey: "anim")
        guard !deathTextures.isEmpty else { return }
        let animate = SKAction.animate(with: deathTextures, timePerFrame: 0.12, resize: true, restore: false)
        sprite.run(SKAction.sequence([animate, .fadeOut(withDuration: 0.2)]), withKey: "anim")
    }

    // MARK: - HeroUnitNode

    /// Лицар: одна головна ціль + сплеш навколо неї, якщо `splashRadius > 0`.
    func attack(with targets: [BaseEnemyNode], in scene: GameScene) {
        guard isAlive, !targets.isEmpty else { return }
        guard tryAttack(whenInRange: true) else { return }

        let splashLogical = unitModel.stats.splashRadius
        let knockback = unitModel.stats.knockback
        let reachMult = scene.size.height > 1 ? SceneLayout.combatReachMultiplier(for: scene.size.height) : 1
        let dealt = resolveOutgoingDamage(base: damagePerHit)

        if splashLogical > 0, let primary = targets.first {
            let splashWorld = CGFloat(splashLogical) * reachMult
            let splashOrigin = CGPoint(x: primary.position.x, y: primary.position.y)

            if primary.applyDamage(dealt) {
                grantCoinReward(for: primary, scene: scene)
            }
            primary.applyKnockback(from: position, strength: knockback)

            playKnightSplashEffect(at: splashOrigin, radius: splashWorld, in: scene)

            for enemy in scene.livingEnemiesForHeroCombat() where enemy !== primary {
                let dist = hypot(enemy.position.x - splashOrigin.x, enemy.position.y - splashOrigin.y)
                guard dist <= splashWorld else { continue }
                if enemy.applyDamage(dealt) {
                    grantCoinReward(for: enemy, scene: scene)
                }
                enemy.applyKnockback(from: position, strength: knockback)
            }
        } else {
            for target in targets {
                if target.applyDamage(dealt) {
                    grantCoinReward(for: target, scene: scene)
                }
                target.applyKnockback(from: position, strength: knockback)
            }
        }
    }

    private func grantCoinReward(for target: BaseEnemyNode, scene: GameScene) {
        let reward = target.unitModel.stats.reward
        let origin = CGPoint(x: target.position.x, y: target.position.y + 10)
        CoinPickupNode.spawn(in: scene, from: origin, to: position) { [weak scene] in
            scene?.addCoins(reward)
        }
    }

    private func playKnightSplashEffect(at worldPoint: CGPoint, radius: CGFloat, in scene: GameScene) {
        let tex = SKTexture(imageNamed: "KnightParticle")
        tex.filteringMode = .nearest
        let node = SKSpriteNode(texture: tex)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        node.position = worldPoint
        node.zPosition = 36
        let base = max(node.size.width, node.size.height)
        let scale: CGFloat = base > 0.5 ? (radius * 2 / base) : 1
        node.setScale(scale)
        node.alpha = 0.88
        scene.addChild(node)
        let grow = SKAction.scale(to: scale * 1.06, duration: 0.16)
        grow.timingMode = .easeOut
        node.run(SKAction.sequence([
            .group([grow, .fadeOut(withDuration: 0.18)]),
            .removeFromParent()
        ]))
    }
}
