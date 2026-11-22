//
//  GameManager.swift
//  PacMan
//
//  Created by Jonathan French on 26.04.26.
//

import Foundation
import SwiftUI
import QuartzCore
import Combine
import Observation

@Observable
class GameManager {
    var fx:SoundFX = SoundFX()
    var metrics:LayoutMetrics?
    var gameState:GameState = .intro
    var lives:Int = GameConstants.Game.Lives
    var score: Int = 0
    var mapX = 0
    var mapY = 0
    var pacManSprite:PacManSprite?
    let randomChance: (Int) -> Bool = { probability in
        Int.random(in: 0...100) < probability
    }
    let yesno: (Bool) -> String = { b in b ? "Yes" : "No" }
    
    var ghostSprites:[GhostSprite] = []
    var tileSize = 0.0
    var lastTimestamp:CFTimeInterval = 0
    var dt = 0.0
    var tiles:[UIImage] = []
    var fruit:[UIImage] = []
    var fruitCollected:[Fruit] = []
    
    let screenData:[[Int]] = [ [01,10,10,10,10,10,10,10,10,10,10,10,10,43,42,10,10,10,10,10,10,10,10,10,10,10,10,00],[03,44,44,44,44,44,44,44,44,44,44,44,44,25,24,44,44,44,44,44,44,44,44,44,44,44,44,02],[03,44,23,20,20,22,44,23,20,20,20,22,44,25,24,44,23,21,21,21,22,44,23,20,20,22,44,02],[03,44,25,44,44,24,44,25,44,44,44,24,44,25,24,44,25,44,44,44,24,44,25,44,44,24,44,02],[03,44,27,15,15,26,44,27,15,15,15,26,44,27,26,44,27,15,15,15,26,44,27,15,15,26,44,02],[03,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,02],[03,44,23,20,20,22,44,23,22,44,23,20,20,20,20,20,20,22,44,23,22,44,23,20,20,22,44,02],[03,44,27,15,15,26,44,24,25,44,27,15,15,22,23,15,15,26,44,24,25,44,27,15,15,26,44,02],[03,44,44,44,44,44,44,24,25,44,44,44,44,25,24,44,44,44,44,24,25,44,44,44,44,44,44,02],[05,12,12,12,12,22,44,24,27,20,20,22,44,25,24,44,23,20,20,26,25,44,23,12,12,12,12,04],[44,44,44,44,44,03,44,24,23,15,15,26,44,27,26,44,27,15,15,22,25,44,02,44,44,44,44,44],[44,44,44,44,44,03,44,24,25,44,44,44,44,44,44,44,44,44,44,24,25,44,02,44,44,44,44,44],[44,44,44,44,44,03,44,24,25,44,29,12,33,44,44,32,12,28,44,24,25,44,02,44,44,44,44,44],[10,10,10,10,10,26,44,27,26,44,02,44,44,44,44,44,44,03,44,27,26,44,27,10,10,10,10,10],[44,44,44,44,44,44,44,44,44,44,02,44,44,44,44,44,44,03,44,44,44,44,44,44,44,44,44,44],[12,12,12,12,12,22,44,23,22,44,02,44,44,44,44,44,44,03,44,23,22,44,23,12,12,12,12,12],[44,44,44,44,44,03,44,24,25,44,31,10,10,10,10,10,10,30,44,24,25,44,02,44,44,44,44,44],[44,44,44,44,44,03,44,24,25,44,44,44,44,44,44,44,44,44,44,24,25,44,02,44,44,44,44,44],[44,44,44,44,44,03,44,24,25,44,23,20,20,20,20,20,20,22,44,24,25,44,02,44,44,44,44,44],[01,10,10,10,10,26,44,27,26,44,27,15,15,22,23,15,15,26,44,27,26,44,27,10,10,10,10,00],[03,44,44,44,44,44,44,44,44,44,44,44,44,25,24,44,44,44,44,44,44,44,44,44,44,44,44,02],[03,44,23,20,20,22,44,23,20,20,20,22,44,25,24,44,23,20,20,20,22,44,23,20,20,22,44,02],[03,44,27,15,22,24,44,27,15,15,15,26,44,27,26,44,27,15,15,15,26,44,25,23,15,26,44,02],[03,44,44,44,25,24,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,25,24,44,44,44,02],[07,20,22,44,25,24,44,23,22,44,23,20,20,20,20,20,20,22,44,23,22,44,25,24,44,23,20,06],[09,15,26,44,27,26,44,24,25,44,27,15,15,22,23,15,15,26,44,24,25,44,27,26,44,27,15,08],[03,44,44,44,44,44,44,24,25,44,44,44,44,25,24,44,44,44,44,24,25,44,44,44,44,44,44,02],[03,44,23,20,20,20,20,26,27,20,20,22,44,25,24,44,23,20,20,26,27,20,20,20,20,22,44,02],[03,44,27,15,15,15,15,15,15,15,15,26,44,27,26,44,27,15,15,15,15,15,15,15,15,26,44,02],[03,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,02],[05,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,04]
    ]

    let map:[String] = [
            "                             ",
            " oooooooooooo  oooooooooooo  ",
            " o    o     o  o     o    o  ",
            " *    o     o  o     o    *  ",
            " o    o     o  o     o    o  ",
            " oooooooooooooooooooooooooo  ",
            " o    o  o        o  o    o  ",
            " o    o  o        o  o    o  ",
            " oooooo  oooo  oooo  oooooo  ",
            "      o     +  +     o       ",
            "      o     +  +     o       ",
            "      o  ++++++++++  o       ",
            "      o  +xxxddxxx+  o       ",
            "      o  +x      x+  o       ",
            "++++++o+++x      x+++o+++++++",
            "      o  +x      x+  o       ",
            "      o  +xxxxxxxx+  o       ",
            "      o  ++++++++++  o       ",
            "      o  +        +  o       ",
            "      o  +        +  o       ",
            " oooooooooooo  oooooooooooo  ",
            " o    o     o  o     o    o  ",
            " o    o     o  o     o    o  ",
            " *oo  ooooooo++ooooooo  oo*  ",
            "   o  o  o        o  o  o    ",
            "   o  o  o        o  o  o    ",
            " oooooo  oooo  oooo  oooooo  ",
            " o          o  o          o  ",
            " o          o  o          o  ",
            " oooooooooooooooooooooooooo  ",
            "                             "]
    
    var workingMap:[String] = []
    // MARK: - Movement

    var moveDirection: Direction = .stop
    var requestedDirection: Direction?
    
    init() {
        ///Here we go, lets have a nice DisplayLink to update our model with the screen refresh.
        let displayLink:CADisplayLink = CADisplayLink(target: self, selector: #selector(refreshModel))
        displayLink.add(to: .main, forMode:.common)
        loadTiles()
        loadFruit()
    }
    
    ///Start the game, make sure everything is set to go in here.
    func start() {
        fx.startSound()
        ghostSprites.removeAll()
        workingMap = map
        fruitCollected = [.cherry,.apple,.orange,.bell,.key]
        pacManSprite = PacManSprite(xPos: 14,yPos: 23, tileSize: CGSize(width: self.tileSize, height: self.tileSize))
        ghostSprites.append(GhostSprite(xPos: 14, yPos: 11, tileSize: CGSize(width: self.tileSize, height: self.tileSize), ghostType: .Blinky))
        ghostSprites.append(GhostSprite(xPos: 12, yPos: 14, tileSize: CGSize(width: self.tileSize, height: self.tileSize), ghostType: .Clyde))
        ghostSprites.append(GhostSprite(xPos: 14, yPos: 14, tileSize: CGSize(width: self.tileSize, height: self.tileSize), ghostType: .Inky))
        ghostSprites.append(GhostSprite(xPos: 16, yPos: 14, tileSize: CGSize(width: self.tileSize, height: self.tileSize), ghostType: .Pinky))
        ghostSprites[0].ghostState = .wandering
        gameState = .playing
    }
    
    func gameOver() {
        gameState = .gameover
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(GameConstants.Delay.GameOver))
            gameState = .intro
        }
    }
    
    ///Reseting the game to go again.
    func reset() {
        
    }

    func eatDot() {
        guard let pacManSprite else { return }

        let tileWidth = pacManSprite.frameSize.width
        let tileHeight = pacManSprite.frameSize.height

        let column = Int(pacManSprite.position.x / tileWidth)
        let row = Int(pacManSprite.position.y / tileHeight)

        guard workingMap.indices.contains(row) else { return }

        var characters = Array(workingMap[row])

        guard characters.indices.contains(column) else { return }

        if characters[column] == "o" {
            score += 10
            characters[column] = "+"
            workingMap[row] = String(characters)
            fx.chompSound()
        }
        if characters[column] == "*" {
            score += 50
            characters[column] = "+"
            workingMap[row] = String(characters)
            fx.intermissionSound()
            //Set ghosts to scared.
        }
    }
    
    private func updatePacMan(deltaTime dt: CGFloat) {

        guard gameState == .playing,
              let pacManSprite else { return }

        if moveDirection != .stop {
            pacManSprite.move(deltaTime: dt)
            checkTunnel(for: pacManSprite)
        }
    }
    
    private func handleJoyPad() {

        guard gameState == .playing,
              let pacManSprite else { return }

        // Try the requested direction
        if let requested = requestedDirection,
           pacManSprite.isAligned(for: requested),
           canMove(direction: requested,for: pacManSprite) {

            pacManSprite.align(for: requested)

            moveDirection = requested
            pacManSprite.direction = requested
            requestedDirection = nil
        }

        // Check whether current direction is blocked
        guard moveDirection != .stop else { return }

        if !canMove(direction: moveDirection,for:pacManSprite) {

            stopAtWall(direction: moveDirection)

            if let newDirection = automaticDirection() {
                pacManSprite.direction = newDirection
                moveDirection = newDirection
            } else {
                pacManSprite.direction = .stop
                moveDirection = .stop
            }
        }
    }
    
    func canMove(direction: Direction, for sprite: SwiftUISprite) -> Bool {

        let tileWidth = sprite.frameSize.width
        let tileHeight = sprite.frameSize.height

        let column = Int(sprite.position.x / tileWidth)
        let row = Int(sprite.position.y / tileHeight)

        var targetX = column
        var targetY = row

        switch direction {
        case .up:
            targetY -= 1
        case .down:
            targetY += 1
        case .left:
            targetX -= 1
        case .right:
            targetX += 1
        case .stop:
            return false
        }

        guard workingMap.indices.contains(targetY) else { return false }

        // Allow horizontal tunnel exits
        if targetY == GameConstants.Screen.TunnelRow {
            if targetX < 0 || targetX >= GameConstants.Screen.Width {
                return true
            }
        }

        guard targetX >= 0,
              targetX < GameConstants.Screen.Width else {
            return false
        }

        let characters = Array(workingMap[targetY])
        
        
        let targetTile = characters[targetX]

        // Ghost-house boundary
        if targetTile == "x" {
            return false
        }

        if let ghost = sprite as? GhostSprite,
           ghost.ghostState == .leavingHouse {

            // Allow movement inside the ghost house
            if (11...16).contains(targetX),
               (13...15).contains(targetY) {
                return true
            }

            // Allow exit through the door
            if targetTile == "d" {
                return true
            }
        }

        // Door is blocked to everyone else
        if targetTile == "d" {
            return false
        }

        return targetTile != " "
        
//        let targetTile = characters[targetX]
//
//        // Maze and ghost-house walls
//        if targetTile == " " || targetTile == "x" {
//            return false
//        }
//
//        // Ghost door: ghosts only
//        if targetTile == "d" {
//            return sprite is GhostSprite
//        }
//
//        return true
    }
    
    func checkTunnel(for sprite: SwiftUISprite) {

        let tileWidth = sprite.frameSize.width
        let mapWidth = CGFloat(GameConstants.Screen.Width) * tileWidth

        guard Int(sprite.position.y / sprite.frameSize.height) == GameConstants.Screen.TunnelRow else {
            return
        }

        switch sprite.direction {

        case .left:
            if sprite.position.x + sprite.frameSize.width / 2 < 0 {
                sprite.position.x = mapWidth - tileWidth / 2
            }

        case .right:
            if sprite.position.x - sprite.frameSize.width / 2 > mapWidth {
                sprite.position.x = tileWidth / 2
            }

        default:
            break
        }
    }

    
    func stopAtWall(direction: Direction) {
        guard let pacManSprite else { return }

        let tileWidth = pacManSprite.frameSize.width
        let tileHeight = pacManSprite.frameSize.height

        let column = Int(pacManSprite.position.x / tileWidth)
        let row = Int(pacManSprite.position.y / tileHeight)

        switch direction {
        case .right:
            pacManSprite.position.x = CGFloat(column + 1) * tileWidth
                - pacManSprite.frameSize.width / 2

        case .left:
            pacManSprite.position.x = CGFloat(column) * tileWidth
                + pacManSprite.frameSize.width / 2

        case .down:
            pacManSprite.position.y = CGFloat(row + 1) * tileHeight
                - pacManSprite.frameSize.height / 2

        case .up:
            pacManSprite.position.y = CGFloat(row) * tileHeight
                + pacManSprite.frameSize.height / 2

        case .stop:
            break
        }
    }
    
    func availableDirections(for sprite: SwiftUISprite) -> [Direction] {
        return [.up, .down, .left, .right].filter {
            canMove(direction: $0, for: sprite)
        }
    }
    
    func automaticDirection() -> Direction? {
        guard let pacManSprite else { return nil }

        let reverseDirection: Direction

        switch pacManSprite.direction {
        case .up:    reverseDirection = .down
        case .down:  reverseDirection = .up
        case .left:  reverseDirection = .right
        case .right: reverseDirection = .left
        case .stop:  return nil
        }

        let options = availableDirections(for: pacManSprite).filter {
            $0 != reverseDirection
        }

        return options.count == 1 ? options.first : nil
    }
    
    
    ///So this is called every screen refresh. So that would be 60 times a second. This is the beating heart of the game.
    ///We are also setting the delta time DT which should be 60 frames but this alows us to compensate if we miss a frame.

    @objc func refreshModel(_ link: CADisplayLink) {

        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }

        dt = CGFloat(link.timestamp - lastTimestamp)
        lastTimestamp = link.timestamp

        if gameState == .playing {

            handleJoyPad()
            updatePacMan(deltaTime: dt)
            eatDot()
            updateGhosts(deltaTime: dt)

            if let pacManSprite {
                pacManSprite.animate()
            }
        }
    }
}
