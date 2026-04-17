//
//  FinaleBossNode.swift
//  PixelHeroDefenseTD
//

import SpriteKit

/// Фінальний бос (хвиля 20): чергування **3 ближніх** ударів і **1 дальньої** (cast + AOE-снаряд над героями).
final class FinaleBossNode: BaseEnemyNode {
    private enum Phase {
        case approachingCenter
        case idleAtCenter
        case chasing
        case attacking
        case returningToCenter
        case casting
        case awaitingProjectile
    }

    private var phase: Phase = .approachingCenter
    private var idleTimer: TimeInterval = 0
    private var didJustFinishRanged = false
    private var meleeHitsSinceLastRanged = 0

    private let centerIdleDuration: TimeInterval = 1.5
    private let postRangedIdleBonus: TimeInterval = 0.55
    private let meleesBeforeRanged = 3

    private let castTextures: [SKTexture]
    private let projectileTextures: [SKTexture]

    /// Множник до `damagePerHit` для AOE по кожному герою (трохи слабше за ближній удар).
    private var aoeDamagePerHero: Double { damagePerHit * 0.62 }

    init(model: EnemyUnitModel) {
        let idle = SpriteSheet.sequentialNamedTextures(baseName: "FinaleBossIdle", endIndex: 8)
        let walk = SpriteSheet.sequentialNamedTextures(baseName: "FinaleBossWalk", endIndex: 8)
        let attack = SpriteSheet.sequentialNamedTextures(baseName: "FinaleBossAttack", endIndex: 10)
        let death = SpriteSheet.horizontalStripTextures(imageNamed: "EliteOrcDeath", frameCount: 4)
        self.castTextures = SpriteSheet.sequentialNamedTextures(baseName: "FinaleBossCast", endIndex: 9)
        self.projectileTextures = SpriteSheet.sequentialNamedTextures(baseName: "FinaleBossProfectile", endIndex: 12)
        super.init(model: model, walk: walk, attack: attack, death: death, idle: idle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    func tickFinaleBossPattern(
        deltaTime dt: TimeInterval,
        scene: SKScene,
        sceneSize: CGSize,
        nearestHero: (SKNode & HeroUnitNode)?,
        reachMult: CGFloat,
        livingHeroesProvider: @escaping () -> [SKNode & HeroUnitNode],
        applyMeleeHit: (SKNode & HeroUnitNode, Double) -> Void,
        applyAOEToAllHeroes: @escaping (Double) -> Void
    ) {
        guard isAlive else { return }
        let center = SceneLayout.bossHoldPoint(in: sceneSize)
        let threshold: CGFloat = 24

        func distTo(_ p: CGPoint) -> CGFloat {
            hypot(position.x - p.x, position.y - p.y)
        }

        switch phase {
        case .approachingCenter:
            if distTo(center) <= threshold {
                phase = .idleAtCenter
                idleTimer = 0
                runIdleAnimationLoop()
            } else {
                moveTowards(center, deltaTime: dt)
            }

        case .idleAtCenter:
            idleTimer += dt
            let targetIdle = didJustFinishRanged ? (centerIdleDuration + postRangedIdleBonus) : centerIdleDuration
            guard idleTimer >= targetIdle else { return }
            didJustFinishRanged = false
            idleTimer = 0
            if meleeHitsSinceLastRanged >= meleesBeforeRanged {
                phase = .casting
                playOneShotAnimation(textures: castTextures, timePerFrame: 0.1) { [weak self] in
                    guard let self, self.isAlive else { return }
                    self.runIdleAnimationLoop()
                    self.phase = .awaitingProjectile
                    self.spawnProjectile(
                        in: scene,
                        sceneSize: sceneSize,
                        livingHeroesProvider: livingHeroesProvider,
                        applyAOE: { [weak self] in
                            guard let self, self.isAlive else { return }
                            applyAOEToAllHeroes(self.aoeDamagePerHero)
                            self.phase = .idleAtCenter
                            self.idleTimer = 0
                            self.didJustFinishRanged = true
                            self.meleeHitsSinceLastRanged = 0
                        }
                    )
                }
            } else {
                phase = .chasing
                runWalkAnimationLoop()
            }

        case .chasing:
            guard let hero = nearestHero else {
                phase = .idleAtCenter
                idleTimer = 0
                runIdleAnimationLoop()
                return
            }
            let dist = distTo(hero.position)
            let meleeReach = combatRange * reachMult
            if dist <= meleeReach {
                phase = .attacking
                applyMeleeHit(hero, damagePerHit)
                playAttackAnimationOnce { [weak self] in
                    guard let self, self.isAlive else { return }
                    self.phase = .returningToCenter
                    self.runWalkAnimationLoop()
                }
                meleeHitsSinceLastRanged += 1
            } else {
                moveTowards(hero.position, deltaTime: dt)
            }

        case .attacking:
            break

        case .returningToCenter:
            if distTo(center) <= threshold {
                phase = .idleAtCenter
                idleTimer = 0
                runIdleAnimationLoop()
            } else {
                moveTowards(center, deltaTime: dt)
            }

        case .casting, .awaitingProjectile:
            break
        }
    }

    private func spawnProjectile(
        in scene: SKScene,
        sceneSize: CGSize,
        livingHeroesProvider: @escaping () -> [SKNode & HeroUnitNode],
        applyAOE: @escaping () -> Void
    ) {
        guard !projectileTextures.isEmpty else {
            applyAOE()
            return
        }
        let heroes = livingHeroesProvider()
        let anchor = centroid(of: heroes) ?? SceneLayout.bossHoldPoint(in: sceneSize)
        let point = CGPoint(x: anchor.x, y: anchor.y + 72)

        let node = SKSpriteNode(texture: projectileTextures[0])
        node.position = point
        node.zPosition = 38
        let s = SceneLayout.enemyDisplayScale(for: sceneSize.height, logicalFrame: 100) * 1.2
        node.setScale(s)
        scene.addChild(node)

        let animate = SKAction.animate(with: projectileTextures, timePerFrame: 0.07, resize: true, restore: false)
        let done = SKAction.run(applyAOE)
        node.run(SKAction.sequence([animate, .removeFromParent(), done]))
    }

    private func centroid(of heroes: [SKNode]) -> CGPoint? {
        guard !heroes.isEmpty else { return nil }
        var sx: CGFloat = 0
        var sy: CGFloat = 0
        for h in heroes {
            sx += h.position.x
            sy += h.position.y
        }
        let n = CGFloat(heroes.count)
        return CGPoint(x: sx / n, y: sy / n)
    }
}
