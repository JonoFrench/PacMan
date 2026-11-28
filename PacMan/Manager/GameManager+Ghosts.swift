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
        
        //guard gameState == .playing else { return }
        updateGhostMode(deltaTime: dt)
        
        for ghost in ghostSprites {
            updateGhost(ghost, deltaTime: dt)
            //            ghost.animate()
        }
    }
    
    func checkPacManEatingIntroGhosts() {
        for ghost in ghostSprites {
            if ghost.ghostState == .scared && ghost.circlesIntersect(center: pacManSprite!.position, diameter: self.tileSize / 2) {
                ghost.ghostState = .dead
                ghost.lastDecisionColumn = -1
                ghost.lastDecisionRow = -1
                pauseAction = true
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(1))
                    pauseAction = false
                    if ghostCaught < 3 {
                        ghostCaught += 1
                    }
                }
            }
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
                addScore(newScore: scoresArray[ghostCaught])
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(1))
                    pauseAction = false
                    ghostCaught += 1
                }
            }
        }
    }
    
    func updateGhost(_ ghost: GhostSprite, deltaTime dt: CGFloat) {
        
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
        
        
        if column != ghost.lastDecisionColumn ||
           row != ghost.lastDecisionRow {

            ghost.snapToTileCentre()
            ghost.lastDecisionColumn = column
            ghost.lastDecisionRow = row

            switch ghost.ghostState {
            case .wandering:
                if let newDirection = scatterDirection(for: ghost) {
                    ghost.direction = newDirection
                }

            case .chasing:
                if let newDirection = chaseDirection(for: ghost) {
                    ghost.direction = newDirection
                }

            case .scared:
                if let newDirection = randomDirection(for: ghost) {
                    ghost.direction = newDirection
                }

            case .dead, .inHouse, .leavingHouse:
                break
            }
        }

        ghost.move(deltaTime: dt)
        // Don't make multiple decisions on the same tile
//        if column != ghost.lastDecisionColumn ||
//            row != ghost.lastDecisionRow {
//            
//            ghost.snapToTileCentre()
//            
//            ghost.lastDecisionColumn = column
//            ghost.lastDecisionRow = row
//            
//            if let newDirection = scatterDirection(for: ghost) {
//                ghost.direction = newDirection
//            }
////            if let newDirection = randomDirection(for: ghost) {
////                ghost.direction = newDirection
////            }
//        }
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

            ghost.ghostState = activeGhostState()

            ghost.flashing = frightState && frightenedFlashing
            ghost.flash = false
            
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
    
    func scatterTarget(for ghost: GhostSprite) -> (x: Int, y: Int) {

        switch ghost.ghost {

        case .Pinky:
            return (3, -2)

        case .Blinky:
            return (25, -2)

        case .Inky:
            return (25, 32)

        case .Clyde:
            return (3, 32)
        }
    }
    
    private func scatterDirection(
        for ghost: GhostSprite
    ) -> Direction? {

        let tileWidth = ghost.frameSize.width
        let tileHeight = ghost.frameSize.height

        let column = Int(ghost.position.x / tileWidth)
        let row = Int(ghost.position.y / tileHeight)

        let target = scatterTarget(for: ghost)

        let available = availableDirections(for: ghost)

        guard !available.isEmpty else {
            return nil
        }

        let reverse = reverseDirection(ghost.direction)

        let options = available.filter {
            $0 != reverse
        }

        // No alternative direction: continue straight
        guard options.count > 1 else {
            return options.first ?? available.first
        }

        let priority: [Direction] = [
            .up, .left, .down, .right
        ]

        var bestDirection: Direction?
        var shortestDistance = Int.max

        for direction in priority {

            guard options.contains(direction) else {
                continue
            }

            var testX = column
            var testY = row

            switch direction {
            case .up:    testY -= 1
            case .down:  testY += 1
            case .left:  testX -= 1
            case .right: testX += 1
            case .stop:  continue
            }

            let dx = target.x - testX
            let dy = target.y - testY

            let distance = dx * dx + dy * dy

            if distance < shortestDistance {
                shortestDistance = distance
                bestDirection = direction
            }
        }

        return bestDirection
    }
    
    func ghostModeSchedule(
        for level: Int
    ) -> [GhostModePhase] {

        let scatter1: TimeInterval = level >= 5 ? 5 : 7
        let scatter2: TimeInterval = level >= 5 ? 5 : 7

        let chase3: TimeInterval =
            level == 1 ? 20 :
            level <= 4 ? 1033 : 1037

        let scatter4: TimeInterval =
            level == 1 ? 5 : 1.0 / 60.0

        return [
            GhostModePhase(mode: .scatter, duration: scatter1),
            GhostModePhase(mode: .chase, duration: 20),
            GhostModePhase(mode: .scatter, duration: scatter2),
            GhostModePhase(mode: .chase, duration: 20),
            GhostModePhase(mode: .scatter, duration: 5),
            GhostModePhase(mode: .chase, duration: chase3),
            GhostModePhase(mode: .scatter, duration: scatter4),
            GhostModePhase(mode: .chase, duration: nil)
        ]
    }
    
    func updateGhostMode(deltaTime dt: CGFloat) {

        guard !frightState else {
            return
        }
        
        let schedule = ghostModeSchedule(for: level)

        var remainingTime = TimeInterval(dt)

        while remainingTime > 0 {

            let phase = schedule[ghostModePhaseIndex]

            // Permanent Chase phase
            guard let duration = phase.duration else {
                return
            }

            let timeRemaining = duration - ghostModeElapsed

            if remainingTime < timeRemaining {
                ghostModeElapsed += remainingTime
                break
            }

            // Move into the next phase
            remainingTime -= timeRemaining
            ghostModeElapsed = 0

            guard ghostModePhaseIndex + 1 < schedule.count else {
                return
            }

            ghostModePhaseIndex += 1

            let nextMode = schedule[ghostModePhaseIndex].mode

            changeGhostMode(to: nextMode)
        }
    }
    
    func changeGhostMode(to mode: GhostMode) {

        print("changeGhostMode from \(currentGhostMode) to \(mode)")
        currentGhostMode = mode

        for ghost in ghostSprites {

            switch ghost.ghostState {

            case .wandering, .chasing:

                ghost.direction = reverseDirection(ghost.direction)

                ghost.ghostState = mode == .scatter
                    ? .wandering
                    : .chasing
            default:
                // Don't disturb frightened, dead or house ghosts
                break
            }
        }
    }
    
    func restoreGhostMode() {

        for ghost in ghostSprites {

            guard ghost.ghostState == .scared else {
                continue
            }

            ghost.flashing = false
            ghost.flash = false

            ghost.ghostState = currentGhostMode == .scatter
                ? .wandering
                : .chasing
        }
    }
    
    func startFrightenedMode() {

        // Cancel any previous frightened timers
        frightenedTask?.cancel()
        flashingTask?.cancel()

        frightState = true
        ghostCaught = 0

        setFrightTimeForLevel()

        for ghost in ghostSprites {

            switch ghost.ghostState {

            case .wandering, .chasing:

                ghost.ghostState = .scared
                ghost.flashing = false
                ghost.flash = false
                ghost.direction = reverseDirection(ghost.direction)

            default:
                break
            }
        }

        // Start flashing near the end
        flashingTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(flashingTime))
            } catch {
                return
            }

            guard frightState else { return }
            frightenedFlashing = true

            for ghost in ghostSprites {
                if ghost.ghostState == .scared {
                    ghost.flashing = true
                }
            }
        }

        // End frightened mode
        frightenedTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(totalTime))
            } catch {
                return
            }

            restoreGhostMode()

            frightenedFlashing = false
            frightState = false

            flashingTask?.cancel()
            flashingTask = nil
            frightenedTask = nil
        }
    }
    
    func resetGhostModes() {

        frightenedTask?.cancel()
        flashingTask?.cancel()

        frightenedTask = nil
        flashingTask = nil

        frightState = false

        ghostModePhaseIndex = 0
        ghostModeElapsed = 0

        currentGhostMode = .scatter
    }
    
    func activeGhostState() -> GhostState {

        if frightState {
            return .scared
        }

        switch currentGhostMode {
        case .scatter:
            return .wandering
        case .chase:
            return .chasing
        }
    }
    
    func chaseTarget(for ghost: GhostSprite) -> (x: Int, y: Int)? {

        guard let pacMan = pacManSprite else {
            return nil
        }

        let tileWidth = ghost.frameSize.width
        let tileHeight = ghost.frameSize.height

        let pacColumn = Int(pacMan.position.x / tileWidth)
        let pacRow = Int(pacMan.position.y / tileHeight)

        switch ghost.ghost {

        case .Blinky:
            // Directly targets Pac-Man
            return (pacColumn, pacRow)

        case .Pinky:
            // Targets four tiles ahead of Pac-Man
            var targetX = pacColumn
            var targetY = pacRow

            switch pacMan.direction {
            case .up:
                targetX -= 4
                targetY -= 4
            case .down:
                targetY += 4
            case .left:
                targetX -= 4
            case .right:
                targetX += 4
            case .stop:
                break
            }

            return (targetX, targetY)

        case .Inky:
            // Two tiles ahead of Pac-Man
            var pivotX = pacColumn
            var pivotY = pacRow

            switch pacMan.direction {
            case .up:
                pivotY -= 2
            case .down:
                pivotY += 2
            case .left:
                pivotX -= 2
            case .right:
                pivotX += 2
            case .stop:
                break
            }

            // Find Blinky's position
            guard let blinky = ghostSprites.first(where: {
                $0.ghost == .Blinky
            }) else {
                return (pacColumn, pacRow)
            }

            let blinkyX = Int(blinky.position.x / tileWidth)
            let blinkyY = Int(blinky.position.y / tileHeight)

            // Double the vector from Blinky to the pivot
            let targetX = pivotX + (pivotX - blinkyX)
            let targetY = pivotY + (pivotY - blinkyY)

            return (targetX, targetY)

        case .Clyde:
            // Clyde chases until he is within eight tiles
            let ghostColumn = Int(ghost.position.x / tileWidth)
            let ghostRow = Int(ghost.position.y / tileHeight)

            let dx = pacColumn - ghostColumn
            let dy = pacRow - ghostRow

            if dx * dx + dy * dy >= 64 {
                return (pacColumn, pacRow)
            } else {
                return scatterTarget(for: ghost)
            }
        }

    }
    
    func chaseDirection(
        for ghost: GhostSprite
    ) -> Direction? {

        let tileWidth = ghost.frameSize.width
        let tileHeight = ghost.frameSize.height

        let column = Int(ghost.position.x / tileWidth)
        let row = Int(ghost.position.y / tileHeight)

        guard let target = chaseTarget(for: ghost) else {
            return nil
        }

        let available = availableDirections(for: ghost)

        guard !available.isEmpty else {
            return nil
        }

        let reverse = reverseDirection(ghost.direction)

        // Avoid reversing unless there is no alternative
        let options = available.filter {
            $0 != reverse
        }

        let candidates = options.isEmpty ? available : options

        let priority: [Direction] = [
            .up, .left, .down, .right
        ]

        var bestDirection: Direction?
        var shortestDistance = Int.max

        for direction in priority {

            guard candidates.contains(direction) else {
                continue
            }

            var testX = column
            var testY = row

            switch direction {
            case .up:    testY -= 1
            case .down:  testY += 1
            case .left:  testX -= 1
            case .right: testX += 1
            case .stop:  continue
            }

            let dx = target.x - testX
            let dy = target.y - testY

            let distance = dx * dx + dy * dy

            if distance < shortestDistance {
                shortestDistance = distance
                bestDirection = direction
            }
        }

        return bestDirection
    }
}
