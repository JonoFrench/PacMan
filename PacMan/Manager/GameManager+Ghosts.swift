//
//  GameManager+Ghosts.swift
//  PacMan
//
//  Created by Jonathan French on 22.11.26.
//

import Foundation
import SwiftUI

extension GameManager {
    
    func updateGhosts(deltaTime dt: CGFloat) {
        
        guard gameState == .playing else { return }
        
        for ghost in ghostSprites {
            updateGhost(ghost, deltaTime: dt)
            //            ghost.animate()
        }
    }
    
    func checkPacManEatingGhosts() {
        for ghost in ghostSprites {
            if ghost.ghostState == .scared && ghost.circlesIntersect(center: pacManSprite!.position, diameter: self.tileSize) {
                ghost.ghostState = .dead
                ghost.lastDecisionColumn = -1
                ghost.lastDecisionRow = -1
                fx.ghostSound()
                pauseAction = true
                score += scoresArray[ghostCaught]
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(1))
                    pauseAction = false
                    ghostCaught += 1
                }
            }
        }
    }
    
    private func updateGhost(_ ghost: GhostSprite, deltaTime dt: CGFloat) {
        
        if ghost.ghostState == .dead {
            updateGhostReturningHome(ghost, deltaTime: dt)
            return
        }
        
        if ghost.ghostState == .inHouse {
            updateGhostInHouse(ghost, deltaTime: dt)
            return
        }
        
        if ghost.ghostState == .leavingHouse {
            
            // Only the first ghost in the queue can move
            guard ghostExitQueue.first == ghost.ghost else {
                return
            }
            
            updateGhostLeavingHouse(ghost, deltaTime: dt)
            return
        }
        let tileWidth = ghost.frameSize.width
        let tileHeight = ghost.frameSize.height
        
        let column = Int(ghost.position.x / tileWidth)
        let row = Int(ghost.position.y / tileHeight)
        
        // Only make a new decision at tile centres
        guard ghost.isAtTileCentre() else {
            ghost.move(deltaTime: dt)
            checkTunnel(for: ghost)
            return
        }
        
        // Don't make multiple decisions on the same tile
        if column != ghost.lastDecisionColumn ||
            row != ghost.lastDecisionRow {
            
            ghost.snapToTileCentre()
            
            ghost.lastDecisionColumn = column
            ghost.lastDecisionRow = row
            
            if let newDirection = randomDirection(for: ghost) {
                ghost.direction = newDirection
            }
        }
        ghost.move(deltaTime: dt)
        
    }
    
    func randomDirection(for ghost: GhostSprite) -> Direction? {
        
        let available = availableDirections(for: ghost)
        
        guard !available.isEmpty else { return nil }
        
        let reverse = reverseDirection(ghost.direction)
        
        let options = available.filter {
            $0 != reverse
        }
        
        return (options.isEmpty ? available : options).randomElement()
    }
    
    func reverseDirection(_ direction: Direction) -> Direction {
        switch direction {
        case .up:    return .down
        case .down:  return .up
        case .left:  return .right
        case .right: return .left
        case .stop:  return .stop
        }
    }
    
    private func updateGhostLeavingHouse(
        _ ghost: GhostSprite,
        deltaTime dt: CGFloat
    ) {
        let tileWidth = ghost.frameSize.width
        let tileHeight = ghost.frameSize.height
        
        let column = Int(ghost.position.x / tileWidth)
        let row = Int(ghost.position.y / tileHeight)
        
        // Only release once we've reached the corridor tile centre
        if row <= 11 && column == 14 && ghost.isAtTileCentre() {
            ghost.ghostState = .wandering
            
            if ghostExitQueue.first == ghost.ghost {
                ghostExitQueue.removeFirst()
            }
            
            return
        }
        
        // Make a decision only once on each new tile
        if ghost.isAtTileCentre() &&
            (column != ghost.lastDecisionColumn ||
             row != ghost.lastDecisionRow) {
            
            ghost.snapToTileCentre()
            ghost.lastDecisionColumn = column
            ghost.lastDecisionRow = row
            
            let exitColumn = 14
            
            let preferredDirection: Direction
            
            if column < exitColumn {
                preferredDirection = .right
            } else if column > exitColumn {
                preferredDirection = .left
            } else {
                preferredDirection = .up
            }
            
            if canMove(direction: preferredDirection, for: ghost) {
                ghost.direction = preferredDirection
            } else {
                ghost.direction = .stop
            }
        }
        
        // Keep moving every frame
        ghost.move(deltaTime: dt)
    }
    
    private func directionToGhostHouse(
        from startX: Int,
        row startY: Int
    ) -> Direction? {
        
        let targetX = 14
        let targetY = 14
        
        if startX == targetX && startY == targetY {
            return nil
        }
        
        var queue: [(x: Int, y: Int, firstDirection: Direction?)] = [
            (startX, startY, nil)
        ]
        
        var visited: Set<Int> = [
            startY * GameConstants.Screen.Width + startX
        ]
        
        let directions: [Direction] = [.up, .down, .left, .right]
        
        var index = 0
        
        while index < queue.count {
            
            let current = queue[index]
            index += 1
            
            for direction in directions {
                
                var nextX = current.x
                var nextY = current.y
                
                switch direction {
                case .up:    nextY -= 1
                case .down:  nextY += 1
                case .left:  nextX -= 1
                case .right: nextX += 1
                case .stop:  continue
                }
                
                guard workingMap.indices.contains(nextY),
                      nextX >= 0,
                      nextX < GameConstants.Screen.Width else {
                    continue
                }
                
                let key = nextY * GameConstants.Screen.Width + nextX
                
                guard !visited.contains(key) else {
                    continue
                }
                
                let tile = Array(workingMap[nextY])[nextX]
                
                let insideHouse =
                (11...16).contains(nextX) &&
                (13...15).contains(nextY)
                
                // Dead ghosts can travel through the door and house interior
                guard tile != "x",
                      tile != " " || insideHouse || tile == "d" else {
                    continue
                }
                
                let firstDirection = current.firstDirection ?? direction
                
                if nextX == targetX && nextY == targetY {
                    return firstDirection
                }
                
                visited.insert(key)
                
                queue.append((
                    nextX,
                    nextY,
                    firstDirection
                ))
            }
        }
        
        return nil
    }
    
    private func updateGhostReturningHome(
        _ ghost: GhostSprite,
        deltaTime dt: CGFloat
    ) {
        let tileWidth = ghost.frameSize.width
        let tileHeight = ghost.frameSize.height
        
        let column = Int(ghost.position.x / tileWidth)
        let row = Int(ghost.position.y / tileHeight)
        
        // Has reached the centre of the house
        if column == 14 && row == 14 && ghost.isAtTileCentre() {
            ghost.snapToTileCentre()
            ghost.ghostState = .inHouse
            ghost.houseTimer = 0
            ghost.direction = .left
            ghost.lastDecisionColumn = -1
            ghost.lastDecisionRow = -1
            return
        }
        
        // Keep moving between tile centres
        guard ghost.isAtTileCentre() else {
            ghost.move(deltaTime: dt)
            checkTunnel(for: ghost)
            return
        }
        
        // Choose a new direction once per tile
        if column != ghost.lastDecisionColumn ||
            row != ghost.lastDecisionRow {
            
            ghost.snapToTileCentre()
            ghost.lastDecisionColumn = column
            ghost.lastDecisionRow = row
            
            if let direction = directionToGhostHouse(
                from: column,
                row: row
            ) {
                ghost.direction = direction
            } else {
                ghost.direction = .stop
            }
        }
        ghost.move(deltaTime: dt)
    }
    
    private func updateGhostInHouse(
        _ ghost: GhostSprite,
        deltaTime dt: CGFloat
    ) {
        ghost.houseTimer += dt
        
        // Recovery complete
        if ghost.houseTimer >= ghost.houseWaitDuration {
            
            if !ghostExitQueue.contains(ghost.ghost) {
                ghostExitQueue.append(ghost.ghost)
            }
            
            ghost.lastDecisionColumn = -1
            ghost.lastDecisionRow = -1
            ghost.ghostState = .leavingHouse
            return
        }
        
        let tileWidth = ghost.frameSize.width
        let tileHeight = ghost.frameSize.height
        
        let column = Int(ghost.position.x / tileWidth)
        let row = Int(ghost.position.y / tileHeight)
        
        guard ghost.isAtTileCentre() else {
            ghost.move(deltaTime: dt)
            return
        }
        
        if column != ghost.lastDecisionColumn ||
            row != ghost.lastDecisionRow {
            
            ghost.snapToTileCentre()
            ghost.lastDecisionColumn = column
            ghost.lastDecisionRow = row
            
            if let direction = randomDirection(for: ghost) {
                ghost.direction = direction
            } else {
                ghost.direction = .stop
            }
        }
        ghost.move(deltaTime: dt)
    }
}
