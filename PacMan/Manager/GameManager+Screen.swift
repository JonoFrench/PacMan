//
//  GameManager+Screen.swift
//  PacMan
//
//  Created by Jonathan French on 21.11.26.
//

import Foundation
import SwiftUI

struct GhostModePhase {
    let mode: GhostMode
    let duration: TimeInterval?
}

extension GameManager {
    
    ///Add to the score
    func addScore(newScore:Int) {
        score += newScore
        ///Extra life every 5000 points
        if score >= nextLifeScore {
            lives += 1
            nextLifeScore += 10000
            fx.extraSound()
        }
    }
    
    func checkCollectFruit() {
        if showFruit, let pacManSprite {
            if pacManSprite.circlesIntersect(center: CGPoint(x: metrics!.centerX, y: tileSize * 17.5), diameter: 12) {
                showFruit = false
                addScore(newScore: bonusForLevel())
                fx.fruitSound()
            }
        } else if dotsCollected == 70 || dotsCollected == 170 {
            showFruit = true
            selectedFruit = fruitForLevel()
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(GameConstants.Time.ShowFruit))
                showFruit = false
            }
        }
    }
    
    func fruitForLevel() -> Fruit {
        if level > levelFruit.count { return .key }
        return levelFruit[level]
    }
    
    func bonusForLevel() -> Int {
        if level >= 12 { return 5000 }
        return levelBonuses[level]
    }

    func setSpeedForLevel() {
        if let pacManSprite {
            if frightState {
                pacManSprite.speedMultiplier = level < 5 ? frightPacForLevel[level] : 1.0
            }
            if level >= 20 {
                pacManSprite.speedMultiplier = dotEaten ? 0.79 : 0.9
                dotEaten = false
                return
            }
            if level >= 4 {
                pacManSprite.speedMultiplier = dotEaten ? 0.87 : 1.0
                dotEaten = false
                return
            }
            if dotEaten {
                pacManSprite.speedMultiplier = dotForLevel[level]
                dotEaten = false
            } else {
                pacManSprite.speedMultiplier = speedForLevel[level]
            }
        }
    }
    
    func setGhostSpeedForLevel() {
        for ghost in ghostSprites {
            if ghost.ghostState == .dead {
                ghost.speedMultiplier = 1.25
                continue
            }
        let column = Int(ghost.position.x / tileSize)
        let row = Int(ghost.position.y / tileSize)
            //is in the tunnel?
            let isInTunnel = row == GameConstants.Screen.TunnelRow && ((0...5).contains(column) || (22...28).contains(column))
            if isInTunnel {
                if level < 5 { ghost.speedMultiplier = tunnelForLevel[level] } else {
                    ghost.speedMultiplier = 0.50
                }
                continue
            }
            if level < 5 {
                ghost.speedMultiplier = frightState ? frightGhostForLevel[level] : ghostForLevel[level]
            } else {
                ghost.speedMultiplier = frightState ? 0.60 : 0.95
            }
        }
    }
    
    func setFrightTimeForLevel() {
        totalTime = level < 18 ? CGFloat(timeForLevel[level]) : 0.0
        flashingTime = totalTime - (CGFloat(flashForLevel[level]) * (4.0 * 0.16))
//        print("totalTime \(totalTime) flashingTime \(flashingTime)")
    }
    func loadTiles() {
        for i in 0..<48 {
            tiles.append(getTile(name: "Tiles2", xPos: i,width: 8,height: 8)!)
            whiteTiles.append(getTile(name: "Tiles3", xPos: i,width: 8,height: 8)!)
        }
    }
    func loadFruit() {
        for i in 0..<8 {
            fruit.append(getTile(name: "Fruit", xPos: i,width: 16,height: 16)!)
        }
    }
    func loadScores() {
        for i in 0..<4 {
            ghostScores.append(getTile(name: "Scores", xPos: i,width: 16,height: 16)!)
        }
    }
    
    ///Get Image from sprite sheet - horizontal
    ///
    func getTile(name:String,xPos:Int,width:Int,height:Int) -> UIImage? {
        guard let image = UIImage(named: name) else { return nil }
        let rect = CGRect(x: xPos * width, y: 0, width: width, height: height)
        guard let cgImage = image.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

}
