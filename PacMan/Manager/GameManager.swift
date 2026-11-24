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
    var ghostScores:[UIImage] = []
    var scoresArray:[Int] = [200,400,800,1600]
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
    
    var ghostExitQueue: [Ghosts] = [
        .Inky,
        .Clyde,
        .Pinky
    ]
    var dotEaten = false
    
    //MARK: - Fruit
    
    var showFruit = false
    var selectedFruit: Fruit = .cherry
    var dotsCollected = 0
    var ghostCaught = 0
    var pauseAction = false
    
    init() {
        ///Here we go, lets have a nice DisplayLink to update our model with the screen refresh.
        let displayLink:CADisplayLink = CADisplayLink(target: self, selector: #selector(refreshModel))
        displayLink.add(to: .main, forMode:.common)
        loadTiles()
        loadFruit()
        loadScores()
    }
    
    ///Start the game, make sure everything is set to go in here.
    func start() {
        fx.startSound()
        gameState = .starting
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(GameConstants.Delay.Start))
            gameState = .starting2
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(GameConstants.Delay.Start2))
                gameState = .playing
            }
            
        }
        
    }
    
    func gameOver() {
        gameState = .gameover
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(GameConstants.Delay.GameOver))
            gameState = .intro
        }
    }
    
    ///Restart after life loss
    func restart() {
        pacManSprite = PacManSprite(xPos: 14,yPos: 23, tileSize: CGSize(width: self.tileSize, height: self.tileSize))
        ghostSprites.removeAll()
        ghostSprites.append(GhostSprite(xPos: 14, yPos: 11, tileSize: CGSize(width: self.tileSize, height: self.tileSize), ghostType: .Blinky))
        ghostSprites.append(GhostSprite(xPos: 12, yPos: 14, tileSize: CGSize(width: self.tileSize, height: self.tileSize), ghostType: .Clyde))
        ghostSprites.append(GhostSprite(xPos: 14, yPos: 14, tileSize: CGSize(width: self.tileSize, height: self.tileSize), ghostType: .Inky))
        ghostSprites.append(GhostSprite(xPos: 16, yPos: 14, tileSize: CGSize(width: self.tileSize, height: self.tileSize), ghostType: .Pinky))
        ghostSprites[0].ghostState = .wandering
        ghostExitQueue = [
            .Inky,
            .Clyde,
            .Pinky
        ]

        start()
    }
    
    ///Reseting the game to go again.
    func reset() {
        ghostSprites.removeAll()
        fruitCollected.removeAll()
        fruitCollected = [.cherry,.apple,.orange,.bell,.key]
        pacManSprite = PacManSprite(xPos: 14,yPos: 23, tileSize: CGSize(width: self.tileSize, height: self.tileSize))
        ghostSprites.append(GhostSprite(xPos: 14, yPos: 11, tileSize: CGSize(width: self.tileSize, height: self.tileSize), ghostType: .Blinky))
        ghostSprites.append(GhostSprite(xPos: 12, yPos: 14, tileSize: CGSize(width: self.tileSize, height: self.tileSize), ghostType: .Clyde))
        ghostSprites.append(GhostSprite(xPos: 14, yPos: 14, tileSize: CGSize(width: self.tileSize, height: self.tileSize), ghostType: .Inky))
        ghostSprites.append(GhostSprite(xPos: 16, yPos: 14, tileSize: CGSize(width: self.tileSize, height: self.tileSize), ghostType: .Pinky))
        ghostSprites[0].ghostState = .wandering
        ghostExitQueue = [
            .Inky,
            .Clyde,
            .Pinky
        ]
        workingMap = map
        lives = 3
        score = 0
        dotsCollected = 0
        ghostCaught = 0
        pauseAction = false
        showFruit = false
        start()
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
            dotEaten = true
            score += 10
            characters[column] = "+"
            workingMap[row] = String(characters)
            dotsCollected += 1
            fx.chompSound()
        }
        if characters[column] == "*" {
            score += 50
            characters[column] = "+"
            workingMap[row] = String(characters)
            fx.intermissionSound()
            //Set ghosts to scared.
            ghostCaught = 0
            for ghost in ghostSprites {
                ghost.ghostState = .scared
                ghost.flashing = false
                ghost.flash = false
            }
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(7))
                for ghost in ghostSprites {
                    if ghost.ghostState == .scared {
                        ghost.flashing = true
                    }
                }
            }
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(10))
                for ghost in ghostSprites {
                    if ghost.ghostState == .scared {
                        ghost.flashing = false
                        ghost.flash = false
                        ghost.ghostState = .wandering
                    }
                }
            }
            
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
        
        // House walls are always blocked
        if targetTile == "x" {
            return false
        }
        
        if let ghost = sprite as? GhostSprite {
            
            let isInsideHouse =
            (11...16).contains(targetX) &&
            (13...15).contains(targetY)
            
            switch ghost.ghostState {
                
            case .dead:
                return isInsideHouse || targetTile == "d" || targetTile == "+"
                
            case .inHouse:
                return isInsideHouse
                
            case .leavingHouse:
                return isInsideHouse || targetTile == "d" || targetTile == "+"
                
            default:
                break
            }
        }
        
        // Normal ghosts cannot use the door
        if targetTile == "d" {
            return false
        }
        
        return targetTile != " "
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
            if !pauseAction {
                handleJoyPad()
                if dotEaten {
                    dotEaten.toggle()
                } else {
                    updatePacMan(deltaTime: dt)
                }
                eatDot()
                updateGhosts(deltaTime: dt)
                checkPacManEatingGhosts()
                checkPacManCaught()
                checkCollectFruit()
            }
            if let pacManSprite {
                pacManSprite.animate()
            }
            for ghost in ghostSprites {
                ghost.animate()
            }
        }
        if gameState == .caught {
            if let pacManSprite {
                pacManSprite.animate()
            }
        }
    }
    
    func checkPacManCaught(){
        if let pacManSprite {
            for ghost in ghostSprites {
                if pacManSprite.circlesIntersect(center: ghost.position, diameter: tileSize) {
                    pacManSprite.direction = .stop
                    pacManSprite.caught = true
                    fx.deathSound()
                    gameState = .caught
                    lives -= 1
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(GameConstants.Delay.Caught))
                        restart()
                    }
                    
                    return
                }
            }
        }
    }
    
    func checkCollectFruit() {
        if showFruit, let pacManSprite {
            if pacManSprite.circlesIntersect(center: CGPoint(x: metrics!.centerX, y: tileSize * 17.5), diameter: 24) {
                showFruit = false
                fruitCollected.append(selectedFruit)
                score += 1000
                fx.fruitSound()
            }
        } else if dotsCollected == 40 {
            showFruit = true
            selectedFruit = Fruit.allCases.randomElement()!
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(GameConstants.Time.ShowFruit))
                showFruit = false
            }
        }
    }
}
