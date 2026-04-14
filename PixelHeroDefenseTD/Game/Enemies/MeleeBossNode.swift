//
//  MeleeBossNode.swift
//  PixelHeroDefenseTD
//

import SpriteKit

/// Melee-бос: йде в центр → пауза → до найближчого героя → удар → назад у центр → idle.
final class MeleeBossNode: BaseEnemyNode {
    private enum Phase {
        case approachingCenter
        case idleAtCenter
        case chasing
        case attacking
        case returningToCenter
    }

    private var phase: Phase = .approachingCenter
    private var idleTimer: TimeInterval = 0
    private let centerPauseDuration: TimeInterval

    init(
        model: EnemyUnitModel,
        centerPauseDuration: TimeInterval,
        walk: [SKTexture],
        attack: [SKTexture],
        death: [SKTexture],
        idle: [SKTexture]
    ) {
        self.centerPauseDuration = centerPauseDuration
        super.init(model: model, walk: walk, attack: attack, death: death, idle: idle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    /// Оновлення AI; `applyMeleeHit` — одноразовий удар по герою (шипи тощо ззовні).
    func tickMeleeBossPattern(
        deltaTime dt: TimeInterval,
        sceneSize: CGSize,
        nearestHero: (SKNode & HeroUnitNode)?,
        reachMult: CGFloat,
        applyMeleeHit: (SKNode & HeroUnitNode, Double) -> Void
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
                runWalkAnimationLoop()
                moveTowards(center, deltaTime: dt)
            }

        case .idleAtCenter:
            idleTimer += dt
            if idleTimer >= centerPauseDuration {
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
            } else {
                runWalkAnimationLoop()
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
                runWalkAnimationLoop()
                moveTowards(center, deltaTime: dt)
            }
        }
    }
}

extension MeleeBossNode {
    static func eliteOrc(model: EnemyUnitModel, pause: TimeInterval) -> MeleeBossNode {
        MeleeBossNode(
            model: model,
            centerPauseDuration: pause,
            walk: SpriteSheet.horizontalStripTextures(imageNamed: "EliteOrcWalk", frameCount: 8),
            attack: SpriteSheet.horizontalStripTextures(imageNamed: "EliteOrcAttack", frameCount: 11),
            death: SpriteSheet.horizontalStripTextures(imageNamed: "EliteOrcDeath", frameCount: 4),
            idle: SpriteSheet.horizontalStripTextures(imageNamed: "EliteOrcIdle", frameCount: 6)
        )
    }

    static func kingSlime(model: EnemyUnitModel, pause: TimeInterval) -> MeleeBossNode {
        MeleeBossNode(
            model: model,
            centerPauseDuration: pause,
            walk: SpriteSheet.horizontalStripTextures(imageNamed: "SlimeWalk", frameCount: 6),
            attack: SpriteSheet.horizontalStripTextures(imageNamed: "SlimeAttack", frameCount: 6),
            death: SpriteSheet.horizontalStripTextures(imageNamed: "SlimeDeath", frameCount: 4),
            idle: SpriteSheet.horizontalStripTextures(imageNamed: "SlimeIdle", frameCount: 6)
        )
    }

    static func armoredBoss(model: EnemyUnitModel, pause: TimeInterval) -> MeleeBossNode {
        MeleeBossNode(
            model: model,
            centerPauseDuration: pause,
            walk: SpriteSheet.horizontalStripTextures(imageNamed: "ArmoredSkeletonWalk", frameCount: 9),
            attack: SpriteSheet.horizontalStripTextures(imageNamed: "ArmoredSkeletonAttack", frameCount: 8),
            death: SpriteSheet.horizontalStripTextures(imageNamed: "ArmoredSkeletonDeath", frameCount: 4),
            idle: SpriteSheet.horizontalStripTextures(imageNamed: "ArmoredSkeletonIdle", frameCount: 6)
        )
    }
}

extension BossKind {
    func makeMeleeBoss(model: EnemyUnitModel) -> MeleeBossNode {
        let pause = bossUnitModel.delaySeconds
        switch self {
        case .eliteOrc: return MeleeBossNode.eliteOrc(model: model, pause: pause)
        case .kingSlime: return MeleeBossNode.kingSlime(model: model, pause: pause)
        case .armoredSkeleton: return MeleeBossNode.armoredBoss(model: model, pause: pause)
        case .void: return MeleeBossNode.eliteOrc(model: model, pause: pause)
        }
    }
}
