//
//  GameManager+Intermission.swift
//  PacMan
//
//  Created by Jonathan French on 26.11.26.
//

import Foundation

extension GameManager {
    
    func intermissionRefresh(){
        switch intermission {
        case .two:
            intermissionTwo()
        case .five:
            intermissionFive()
        case.nine:
            intermissionNine()
        }
    }
    
    func setUp(intermission:Intermission) {
        introAnimation = false
        self.intermission = intermission
        switch intermission {
        case .two:
            fruitCollected = [.cherry,.strawberry]
            ghostSprites.removeAll()
            pacManSprite = PacManSprite(xPos: 34,yPos: 15, tileSize: CGSize(width: self.tileSize, height: self.tileSize), gameSpeed: gameSpeed)
            ghostSprites.append(GhostSprite(xPos: 38, yPos: 15, tileSize: CGSize(width: self.tileSize, height: self.tileSize), gameSpeed: gameSpeed, ghostType: .Blinky))
            pacManSprite?.speedMultiplier = 0.80
            pacManSprite?.direction = .left
            ghostSprites[0].speedMultiplier = 0.85
            ghostSprites[0].direction = .left
            
        case .five:
            fruitCollected = [.cherry,.strawberry,.peach,.apple,.grape]
            ghostSprites.removeAll()
            pacManSprite = PacManSprite(xPos: 34,yPos: 15, tileSize: CGSize(width: self.tileSize, height: self.tileSize), gameSpeed: gameSpeed)
            ghostSprites.append(GhostSprite(xPos: 48, yPos: 15, tileSize: CGSize(width: self.tileSize, height: self.tileSize), gameSpeed: gameSpeed, ghostType: .Blinky))
            pacManSprite?.speedMultiplier = 0.80
            pacManSprite?.direction = .left
            ghostSprites[0].speedMultiplier = 0.85
            ghostSprites[0].direction = .left
            ghostSprites[0].secondFrame = ghostSprites[0].inter5Frames[0]
        case .nine:
            fruitCollected = [.cherry,.strawberry,.peach,.apple,.grape,.galaxian,.bell,.key,.key]
            ghostSprites.removeAll()
            pacManSprite = PacManSprite(xPos: 34,yPos: 15, tileSize: CGSize(width: self.tileSize, height: self.tileSize), gameSpeed: gameSpeed)
            ghostSprites.append(GhostSprite(xPos: 39, yPos: 15, tileSize: CGSize(width: self.tileSize, height: self.tileSize), gameSpeed: gameSpeed, ghostType: .Blinky))
            pacManSprite?.speedMultiplier = 0.80
            pacManSprite?.direction = .left
            ghostSprites[0].speedMultiplier = 0.85
            ghostSprites[0].direction = .left
        }
        fx.intermissionSound()
    }
    
    func intermissionTwo(){
        if let pacManSprite, let metrics {
            pacManSprite.move(deltaTime: dt)
            pacManSprite.animate()
            
            for ghost in ghostSprites {
                ghost.move(deltaTime: dt)
                ghost.animate()
                if ghost.position.x < -20 {
                    ghost.direction = .right
                    ghost.ghostState = .scared
                    ghost.speedMultiplier = 0.8
                    pacManSprite.setBig()
                }
                if ghost.direction == .right && pacManSprite.position.x > metrics.width + 60 {
                    goNextLevel()                }
            }
        }
    }
    
    func intermissionFive(){
        if let pacManSprite, let metrics {
            pacManSprite.move(deltaTime: dt)
            pacManSprite.animate()
            if introAnimation {
                for ghost in ghostSprites {
                    if ghost.animateCounter == -1 {
                        Task { @MainActor in
                            try? await Task.sleep(for: .seconds(GameConstants.Delay.Caught))
                            goNextLevel()
                        }
                        
                    } else {
                        ghost.animateFive(deltaTime: dt)
                    }
                }
            } else {
                
                for ghost in ghostSprites {
                    if ghost.position.x < (metrics.width / 2) + 2 {
                        introAnimation = true
                        ghost.animateCounter = 0
                        ghost.currentAnimationFrame = 0
                        continue
                    } else {
                        ghost.animate()
                    }
                    ghost.move(deltaTime: dt)
                }
            }
        }
        
        
    }
    
    func intermissionNine(){
        if let pacManSprite, let metrics {
            pacManSprite.move(deltaTime: dt)
            pacManSprite.animate()
            
            for ghost in ghostSprites {
                ghost.move(deltaTime: dt)
                ghost.animateNine()
                if ghost.position.x < -40 {
                    ghost.direction = .right
                    ghost.speedMultiplier = 0.8
                }
                if ghost.direction == .right && ghost.position.x > metrics.width + 50 {
                    goNextLevel()                }
            }
        }    }
}
