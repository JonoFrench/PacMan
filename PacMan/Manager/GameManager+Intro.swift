//
//  GameManager+Intro.swift
//  PacMan
//
//  Created by Jonathan French on 26.11.26.
//

import Foundation

extension GameManager {
    
    func introRefresh(){
        if let pacManSprite {
             if !pauseAction {
                 pacManSprite.move(deltaTime: dt)
                 pacManSprite.animate()
                 
                 for ghost in ghostSprites {
                     ghost.move(deltaTime: dt)
                     ghost.animate()
                 }
                 
                 if pacManSprite.position.x <= 50 {
                     introDot = false
                     pacManSprite.direction = .right
                     for ghost in ghostSprites {
                         ghost.direction = .right
                         ghost.ghostState = .scared
                         ghost.speedMultiplier = 0.50
                     }
                 }
                 if pacManSprite.position.x >= metrics!.width + (metrics!.isPad ? 150 : 100) {
                     introSprites2()
                     gameState = .intro2
                 }
                 checkPacManEatingIntroGhosts()
             }
         }
    }
    
    func introRefresh2(){
        handleJoyPad()
        eatDot()
        setSpeedForLevel()
        setGhostSpeedForLevel()
        updatePacMan(deltaTime: dt)
        updateGhosts(deltaTime: dt)
        checkPacManEatingGhosts()
        checkCollectFruit()

        if let pacManSprite {
            pacManSprite.animate()
        }
        for ghost in ghostSprites {
            ghost.animate()
        }
    }
    
    func introSprites(){
        if let metrics {
            introDot = true
            pacManSprite = PacManSprite(xPos: 32,yPos: metrics.isPad ? 27 : 39, tileSize: CGSize(width: self.tileSize, height: self.tileSize), gameSpeed: gameSpeed)
            pacManSprite?.direction = .left
            pacManSprite?.speedMultiplier = 0.8
            ghostSprites.removeAll()
            ghostSprites.append(GhostSprite(xPos: 34, yPos: metrics.isPad ? 27 : 39, tileSize: CGSize(width: self.tileSize, height: self.tileSize), gameSpeed: gameSpeed, ghostType: .Blinky))
            ghostSprites.append(GhostSprite(xPos: 36, yPos: metrics.isPad ? 27 : 39, tileSize: CGSize(width: self.tileSize, height: self.tileSize), gameSpeed: gameSpeed, ghostType: .Clyde))
            ghostSprites.append(GhostSprite(xPos: 38, yPos: metrics.isPad ? 27 : 39, tileSize: CGSize(width: self.tileSize, height: self.tileSize), gameSpeed: gameSpeed, ghostType: .Inky))
            ghostSprites.append(GhostSprite(xPos: 40, yPos: metrics.isPad ? 27 : 39, tileSize: CGSize(width: self.tileSize, height: self.tileSize), gameSpeed: gameSpeed, ghostType: .Pinky))
            for ghost in ghostSprites {
                ghost.ghostState = .wandering
                ghost.direction = .left
                ghost.speedMultiplier = 0.8
                
            }
            fruitCollected.removeAll()
            fruitCollected.append(.cherry)
            workingMap = map
        }
    }
    
    func introSprites2() {
        ghostSprites.removeAll()
        fruitCollected.removeAll()
        fruitCollected = []
        pacManSprite = PacManSprite(xPos: 14,yPos: 23, tileSize: CGSize(width: self.tileSize, height: self.tileSize), gameSpeed: gameSpeed)
        ghostSprites.append(GhostSprite(xPos: 14, yPos: 11, tileSize: CGSize(width: self.tileSize, height: self.tileSize), gameSpeed: gameSpeed, ghostType: .Blinky))
        ghostSprites.append(GhostSprite(xPos: 12, yPos: 14, tileSize: CGSize(width: self.tileSize, height: self.tileSize), gameSpeed: gameSpeed, ghostType: .Clyde))
        ghostSprites.append(GhostSprite(xPos: 14, yPos: 14, tileSize: CGSize(width: self.tileSize, height: self.tileSize), gameSpeed: gameSpeed, ghostType: .Inky))
        ghostSprites.append(GhostSprite(xPos: 16, yPos: 14, tileSize: CGSize(width: self.tileSize, height: self.tileSize), gameSpeed: gameSpeed, ghostType: .Pinky))
        ghostSprites[0].ghostState = .wandering
        ghostExitQueue = [
            .Inky,
            .Clyde,
            .Pinky
        ]
        workingMap = map
        lives = 3
        score = 0
        nextLifeScore = 10000
        level = 0
        dotsCollected = 0
        energisersEaten = 0
        ghostCaught = 0
        pauseAction = false
        showFruit = false
        fruitCollected.append(fruitForLevel())
        setSpeedForLevel()
        pacManSprite?.direction = .right
        moveDirection = .right
        requestedDirection = .up

    }
    
}
