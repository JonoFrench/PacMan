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
            ghost.animate()
        }
    }
    
    private func updateGhost(_ ghost: GhostSprite, deltaTime dt: CGFloat) {
//        if ghost.ghostState == .leavingHouse {
//            updateGhostLeavingHouse(ghost, deltaTime: dt)
//            return
//        }

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

        // Reached the corridor above the house
        if row <= 11 {
            ghost.ghostState = .wandering
            return
        }

        // Keep moving until the next tile centre
        guard ghost.isAtTileCentre() else {
            ghost.move(deltaTime: dt)
            return
        }

        ghost.snapToTileCentre()

        let exitColumn = 14

        let direction: Direction

        if column < exitColumn {
            direction = .right
        } else if column > exitColumn {
            direction = .left
        } else {
            direction = .up
        }

        if canMove(direction: direction, for: ghost) {
            ghost.direction = direction
        }

        ghost.move(deltaTime: dt)
    }
}
