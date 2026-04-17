//
//  BaseEnemyNode.swift
//  PixelHeroDefenseTD
//

import SpriteKit

class BaseEnemyNode: SKNode {
    private let sprite = SKSpriteNode()
    private let hpBar = HealthBarNode(fillColor: .red)
    private let logicalFrame: CGFloat = 100

    fileprivate let walkTextures: [SKTexture]
    fileprivate let attackTextures: [SKTexture]
    fileprivate let deathTextures: [SKTexture]
    private let idleTextures: [SKTexture]

    private(set) var unitModel: EnemyUnitModel
    private(set) var currentHP: Double
    private var attackCooldown: TimeInterval = 0
    private(set) var isDead = false
    private var slowRemaining: TimeInterval = 0
    private var slowPercent: Double = 0

    init(model: EnemyUnitModel, walk: [SKTexture], attack: [SKTexture], death: [SKTexture], idle: [SKTexture] = []) {
        self.unitModel = model
        self.currentHP = model.stats.baseHP
        self.walkTextures = walk
        self.attackTextures = attack
        self.deathTextures = death
        self.idleTextures = idle
        super.init()

        if let first = walk.first {
            sprite.texture = first
            sprite.size = first.size()
        }
		
        addChild(sprite)
		
        hpBar.position = CGPoint(x: 0, y: 52)
        hpBar.zPosition = 25
        addChild(hpBar)
        updateHPBar()
        runWalkAnimationLoop()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    var isAlive: Bool { !isDead && currentHP > 0 }
    var combatRange: CGFloat { CGFloat(unitModel.stats.range) }
    var damagePerHit: Double { unitModel.stats.baseDamage }
    var moveSpeed: CGFloat { CGFloat(unitModel.stats.moveSpeed) }

    func updateScale(forSceneHeight height: CGFloat) {
        let base = SceneLayout.enemyDisplayScale(for: height, logicalFrame: logicalFrame)
        let roleMultiplier: CGFloat
        switch unitModel.role {
        case .orc:
            roleMultiplier = 1.2
        case .slime:
			 roleMultiplier = 0.6
		  case .skeleton:
			 roleMultiplier = 1.2
		  case .armoredOrc:
			 roleMultiplier = 1.2
		  case .armoredSkeleton:
			 roleMultiplier = 1.2
		  case .swordsmanSkeleton:
			 roleMultiplier = 1.2
		  case .werewolf:
			 roleMultiplier = 1.2
        case .werebear:
			 roleMultiplier = 1.3
        case .eliteOrcBoss:
            roleMultiplier = 1.85
        case .kingSlimeBoss:
            roleMultiplier = 1.85 * 1.22
        case .armoredSkeletonBoss:
            roleMultiplier = 1.85
        case .void:
            roleMultiplier = 1.95
        }
        let finalScale = base * roleMultiplier
        sprite.setScale(finalScale)
        hpBar.setScale(max(0.75, finalScale))
    }

    func updateTick(deltaTime: TimeInterval) {
        attackCooldown = max(0, attackCooldown - deltaTime)
        if slowRemaining > 0 {
            slowRemaining = max(0, slowRemaining - deltaTime)
            if slowRemaining == 0 {
                slowPercent = 0
            }
        }
    }

    func moveTowards(_ target: CGPoint, deltaTime: TimeInterval) {
        guard isAlive else { return }
        let dx = target.x - position.x
        let dy = target.y - position.y
        let length = max(0.0001, sqrt(dx * dx + dy * dy))
        let dir = CGPoint(x: dx / length, y: dy / length)
        let speedMultiplier = max(0.1, 1.0 - CGFloat(min(0.9, max(0.0, slowPercent))))
        let speed = moveSpeed * speedMultiplier * CGFloat(deltaTime) * 80
        position.x += dir.x * speed
        position.y += dir.y * speed
    }

    /// Накласти уповільнення на ворога (наприклад 0.2 = -20% швидкості) на певний час.
    func applySlow(percent: Double, duration: TimeInterval) {
        guard isAlive, percent > 0, duration > 0 else { return }
        slowPercent = max(slowPercent, min(0.9, percent))
        slowRemaining = max(slowRemaining, duration)
    }

    /// Коротке відкидування від точки-джерела (героя).
    func applyKnockback(from source: CGPoint, strength: Double) {
        guard isAlive, strength > 0 else { return }
        let dx = position.x - source.x
        let dy = position.y - source.y
        let length = max(0.0001, sqrt(dx * dx + dy * dy))
        let dirX = dx / length
        let dirY = dy / length
        let distance = CGFloat(8 + (strength * 10))
        removeAction(forKey: "knockback")
        let push = SKAction.moveBy(x: dirX * distance, y: dirY * distance, duration: 0.08)
        push.timingMode = .easeOut
        run(push, withKey: "knockback")
    }

    func tryAttack(whenInRange: Bool) -> Bool {
        guard whenInRange, isAlive, attackCooldown <= 0 else { return false }
        attackCooldown = 1.0 / max(0.2, unitModel.stats.attackSpeed)
        playAttackThenResumeWalk()
        return true
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

    private func updateHPBar() {
        let maxHP = max(1, unitModel.stats.baseHP)
        hpBar.setProgress(CGFloat(currentHP / maxHP))
    }

    func runWalkAnimationLoop() {
        sprite.removeAction(forKey: "anim")
        guard !walkTextures.isEmpty else { return }
        let animate = SKAction.animate(with: walkTextures, timePerFrame: 0.12, resize: true, restore: true)
        sprite.run(SKAction.repeatForever(animate), withKey: "anim")
    }

    func runIdleAnimationLoop() {
        sprite.removeAction(forKey: "anim")
        guard !idleTextures.isEmpty else {
            runWalkAnimationLoop()
            return
        }
        let animate = SKAction.animate(with: idleTextures, timePerFrame: 0.12, resize: true, restore: true)
        sprite.run(SKAction.repeatForever(animate), withKey: "anim")
    }

    func playAttackAnimationOnce(completion: @escaping () -> Void) {
        sprite.removeAction(forKey: "anim")
        guard !attackTextures.isEmpty else {
            completion()
            return
        }
        let animate = SKAction.animate(with: attackTextures, timePerFrame: 0.08, resize: true, restore: true)
        let done = SKAction.run(completion)
        sprite.run(SKAction.sequence([animate, done]), withKey: "anim")
    }

    /// Одноразова анімація (cast тощо); після завершення викликається `completion`.
    func playOneShotAnimation(
        textures: [SKTexture],
        timePerFrame: TimeInterval = 0.09,
        completion: @escaping () -> Void
    ) {
        sprite.removeAction(forKey: "anim")
        guard !textures.isEmpty else {
            completion()
            return
        }
        let animate = SKAction.animate(with: textures, timePerFrame: timePerFrame, resize: true, restore: true)
        sprite.run(SKAction.sequence([animate, .run(completion)]), withKey: "anim")
    }

    private func playAttackThenResumeWalk() {
        sprite.removeAction(forKey: "anim")
        guard !attackTextures.isEmpty else {
            runWalkAnimationLoop()
            return
        }
        let animate = SKAction.animate(with: attackTextures, timePerFrame: 0.08, resize: true, restore: true)
        let done = SKAction.run { [weak self] in self?.runWalkAnimationLoop() }
        sprite.run(SKAction.sequence([animate, done]), withKey: "anim")
    }

    private func playDeath() {
        sprite.removeAction(forKey: "anim")
        guard !deathTextures.isEmpty else { return }
        let animate = SKAction.animate(with: deathTextures, timePerFrame: 0.10, resize: true, restore: false)
        sprite.run(SKAction.sequence([animate, .fadeOut(withDuration: 0.2)]), withKey: "anim")
    }
}
