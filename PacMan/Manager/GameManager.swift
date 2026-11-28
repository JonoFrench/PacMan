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
    var nextLifeScore = 10000
    var score: Int = 0 {
        didSet {
            if score > hiscore {
                hiscore = score
            }
        }
    }
    var hiscore: Int {
        get {
            UserDefaults.standard.integer(forKey: "hiscore")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hiscore")
        }
    }
    var level: Int = 0
    var mapX = 0
    var mapY = 0
    var gameSpeed: CGFloat = 0
    var pacManSprite:PacManSprite?
    var ghostSprites:[GhostSprite] = []
    var tileSize = 0.0
    var lastTimestamp:CFTimeInterval = 0
    var dt = 0.0
    var tiles:[UIImage] = []
    var whiteTiles:[UIImage] = []
    var fruit:[UIImage] = []
    var ghostScores:[UIImage] = []
    var scoresArray:[Int] = [200,400,800,1600]
    var fruitCollected:[Fruit] = []
    
    let levelFruit:[Fruit] = [.cherry,.strawberry,.peach,.peach,.apple,.apple,.grape,.grape,.galaxian,.galaxian,.bell,.bell,.key]
    
    let screenData:[[Int]] = [ [01,10,10,10,10,10,10,10,10,10,10,10,10,43,42,10,10,10,10,10,10,10,10,10,10,10,10,00],[03,44,44,44,44,44,44,44,44,44,44,44,44,25,24,44,44,44,44,44,44,44,44,44,44,44,44,02],[03,44,23,15,15,22,44,23,15,15,15,22,44,25,24,44,23,15,15,15,22,44,23,15,15,22,44,02],[03,44,25,44,44,24,44,25,44,44,44,24,44,25,24,44,25,44,44,44,24,44,25,44,44,24,44,02],[03,44,27,20,20,26,44,27,20,20,20,26,44,27,26,44,27,20,20,20,26,44,27,20,20,26,44,02],[03,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,02],[03,44,23,15,15,22,44,23,22,44,23,15,15,15,15,15,15,22,44,23,22,44,23,15,15,22,44,02],[03,44,27,20,20,26,44,25,24,44,27,20,20,35,34,20,20,26,44,25,24,44,27,20,20,26,44,02],[03,44,44,44,44,44,44,25,24,44,44,44,44,25,24,44,44,44,44,25,24,44,44,44,44,44,44,02],[05,12,12,12,12,22,44,25,36,15,15,22,44,25,24,44,23,15,15,37,24,44,23,12,12,12,12,04],[44,44,44,44,44,03,44,25,34,20,20,26,44,27,26,44,27,20,20,35,24,44,02,44,44,44,44,44],[44,44,44,44,44,03,44,25,24,44,44,44,44,44,44,44,44,44,44,25,24,44,02,44,44,44,44,44],[44,44,44,44,44,03,44,25,24,44,29,12,33,44,44,32,12,28,44,25,24,44,02,44,44,44,44,44],[10,10,10,10,10,26,44,27,26,44,02,44,44,44,44,44,44,03,44,27,26,44,27,10,10,10,10,10],[44,44,44,44,44,44,44,44,44,44,02,44,44,44,44,44,44,03,44,44,44,44,44,44,44,44,44,44],[12,12,12,12,12,22,44,23,22,44,02,44,44,44,44,44,44,03,44,23,22,44,23,12,12,12,12,12],[44,44,44,44,44,03,44,25,24,44,31,10,10,10,10,10,10,30,44,25,24,44,02,44,44,44,44,44],[44,44,44,44,44,03,44,25,24,44,44,44,44,44,44,44,44,44,44,25,24,44,02,44,44,44,44,44],[44,44,44,44,44,03,44,25,24,44,23,15,15,15,15,15,15,22,44,25,24,44,02,44,44,44,44,44],[01,10,10,10,10,26,44,27,26,44,27,20,20,35,34,20,20,26,44,27,26,44,27,10,10,10,10,00],[03,44,44,44,44,44,44,44,44,44,44,44,44,25,24,44,44,44,44,44,44,44,44,44,44,44,44,02],[03,44,23,15,15,22,44,23,15,15,15,22,44,25,24,44,23,15,15,15,22,44,23,15,15,22,44,02],[03,44,27,20,35,24,44,27,20,20,20,26,44,27,26,44,27,20,20,20,26,44,25,34,20,26,44,02],[03,44,44,44,25,24,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,25,24,44,44,44,02],[07,15,22,44,25,24,44,23,22,44,23,15,15,15,15,15,15,22,44,23,22,44,25,24,44,23,15,06],[09,20,26,44,27,26,44,25,24,44,27,20,20,35,34,20,20,26,44,25,24,44,27,26,44,27,20,08],[03,44,44,44,44,44,44,25,24,44,44,44,44,25,24,44,44,44,44,25,24,44,44,44,44,44,44,02],[03,44,23,15,15,15,15,37,36,15,15,22,44,25,24,44,23,15,15,37,36,15,15,15,15,22,44,02],[03,44,27,20,20,20,20,20,20,20,20,26,44,27,26,44,27,20,20,20,20,20,20,20,20,26,44,02],[03,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,02],[05,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,04]
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
    
    //Level settings
    let levelBonuses: [Int] = [100,300,500,500,700,700,1000,1000,2000,2000,3000,3000,5000]
    
    let speedForLevel: [CGFloat] = [0.8,0.9,0.9,0.9,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0]
    let ghostForLevel: [CGFloat] = [0.75,0.85,0.85,0.85,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95]
    let dotForLevel: [CGFloat] = [0.71,0.79,0.79,0.87,0.87,0.87,0.87,0.87,0.87,0.87,0.87,0.87,0.87]
    let tunnelForLevel: [CGFloat] = [0.40,0.45,0.45,0.45,0.50,0.50]
    let frightPacForLevel: [CGFloat] = [0.9,0.95,0.95,0.95,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0]
    let frightDotForLevel: [CGFloat] = [0.8,0.9,0.9,0.9,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0]
    let frightGhostForLevel: [CGFloat] = [0.5,0.55,0.55,0.55,0.60,0.60,0.60,0.60]
    
    // Scared ghost chase mode
    var frightState = false
    var flashingTime = 0.0
    var totalTime = 0.0
    let timeForLevel: [Int] = [6,5,4,3,2,5,2,2,1,5,2,1,1,3,1,1,0,1,0,0,0]
    let flashForLevel: [Int] = [5,5,5,5,5,5,5,5,3,5,5,3,3,5,3,3,0,3,0,0,0]
    
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
    var energisersEaten = 0
    var ghostCaught = 0
    var pauseAction = false
    
    //MARK: - Intro
    
    var introAnimation = false
    var introDot = true
    
    //MARK: - Intermission
    
    var intermission:Intermission = .two
    
    //MARK: - Ghost Mode

    var ghostModePhaseIndex = 0
    var ghostModeElapsed: TimeInterval = 0

    var currentGhostMode: GhostMode = .scatter

    // This should connect to your existing frightened-mode timer/state.
    var isFrightenedModeActive = false

    var frightenedTask: Task<Void, Never>?
    var flashingTask: Task<Void, Never>?
    var frightenedFlashing = false
    

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
        resetGhostModes()
        setSprites()
        start()
    }
    
    ///Reseting the game to go again.
    func reset() {
        fruitCollected.removeAll()
        fruitCollected = []
        setSprites()
        workingMap = map
        lives = 5
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
        resetGhostModes()
        start()
    }
    
    func setSprites() {
        ghostSprites.removeAll()
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
            addScore(newScore: 10)
            characters[column] = "+"
            workingMap[row] = String(characters)
            dotsCollected += 1
            fx.chompSound()
            if dotsCollected == 240 && energisersEaten == 4 {
                //Ok so next level
                checkLevel()
            }
        }
        if characters[column] == "*" {
            dotEaten = true
            addScore(newScore: 50)
            energisersEaten += 1
            characters[column] = "+"
            workingMap[row] = String(characters)
            if dotsCollected == 240 && energisersEaten == 4 {
                //Ok so next level
                checkLevel()
            }
            // Start frightened mode
            startFrightenedMode()
            //            fx.intermissionSound()
            //Set ghosts to scared.
            //            frightState = true
            //            ghostCaught = 0
            //            setFrightTimeForLevel()
            //            for ghost in ghostSprites {
            //
            //                switch ghost.ghostState {
            //
            //                case .wandering, .chasing:
            //
            //                    ghost.ghostState = .scared
            //                    ghost.flashing = false
            //                    ghost.flash = false
            //
            //                    // Reverse direction when frightened begins
            //                    ghost.direction = reverseDirection(ghost.direction)
            //
            //                default:
            //                    break
            //                }
            //            }
            ////            for ghost in ghostSprites {
            ////                ghost.ghostState = .scared
            ////                ghost.flashing = false
            ////                ghost.flash = false
            ////            }
            //            Task { @MainActor in
            //                try? await Task.sleep(for: .seconds(flashingTime))
            //                for ghost in ghostSprites {
            //                    if ghost.ghostState == .scared {
            //                        ghost.flashing = true
            //                    }
            //                }
            //            }
            //            Task { @MainActor in
            //                try? await Task.sleep(for: .seconds(totalTime))
            //                for ghost in ghostSprites {
            //                    if ghost.ghostState == .scared {
            //                        ghost.flashing = false
            //                        ghost.flash = false
            //                        ghost.ghostState = .wandering
            //                    }
            //                }
            Task { @MainActor in
                
                try? await Task.sleep(for: .seconds(totalTime))
                
                restoreGhostMode()
                
                frightState = false
            }
        }
    }
    
    func checkLevel(){
        pauseAction = true
        level += 1
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            gameState = .nextlevel
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(3))
                
                if level == 2 {
                    intermission = .two
                }
                else if level == 5 {
                    intermission = .five
                }
                else if level == 9 {
                    intermission = .nine
                } else {
                    goNextLevel()
                    return
                }
                setUp(intermission: intermission)
                gameState = .intermission
            }
        }
    }
    
    func goNextLevel() {
                pauseAction = false
                dotsCollected = 0
                energisersEaten = 0
                workingMap = map
                fruitCollected.append(fruitForLevel())
                setSpeedForLevel()
                restart()
    }
    
    func updatePacMan(deltaTime dt: CGFloat) {
        
        guard gameState == .playing || gameState == .intro2,
              let pacManSprite else { return }
        
        if moveDirection != .stop {
            pacManSprite.move(deltaTime: dt)
            checkTunnel(for: pacManSprite)
        }
    }
    
    func handleJoyPad() {
        
        guard gameState == .playing || gameState == .intro2,
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
        
        if gameState == .intro && introAnimation {
            introRefresh()
        }
        if gameState == .intro2 {
            introRefresh2()
        }
        
        if gameState == .intermission {
            intermissionRefresh()
        }
        
        if gameState == .playing {
            if !pauseAction {
                handleJoyPad()
                eatDot()
                setSpeedForLevel()
                setGhostSpeedForLevel()
                updatePacMan(deltaTime: dt)
                updateGhosts(deltaTime: dt)
                checkPacManEatingGhosts()
//                checkPacManCaught()
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
                if ghost.ghostState == .chasing || ghost.ghostState == .wandering {
                    if pacManSprite.circlesIntersect(center: ghost.position, diameter: tileSize) {
                        pacManSprite.direction = .stop
                        pacManSprite.caught = true
                        fx.deathSound()
                        gameState = .caught
                        lives -= 1
                        Task { @MainActor in
                            try? await Task.sleep(for: .seconds(GameConstants.Delay.Caught))
                            if lives == 0 {
                                gameState = .gameover
                                Task { @MainActor in
                                    try? await Task.sleep(for: .seconds(GameConstants.Delay.GameOver))
                                    gameState = .intro
                                }
                                
                            } else {
                                restart()
                            }
                        }
                        return
                    }
                }
            }
        }
    }
    
}
