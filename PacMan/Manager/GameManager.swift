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
    
    var sprite:PacManSprite?
    var ghostSprites:[GhostSprite] = []
    var tileSize = 0.0
    var lastTimestamp:CFTimeInterval = 0
    var dt = 0.0
    var tiles:[UIImage] = []

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
            "      o  +        +  o       ",
            "      o  +        +  o       ",
            "++++++o+++        +++o+++++++",
            "      o  +        +  o       ",
            "      o  +        +  o       ",
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
    
    // MARK: - Movement
    var moveDirection: JoyPad = .stop {
        didSet {
            if moveDirection != oldValue {
                handleJoyPad()
            }
        }
    }

    
    init() {
        ///Here we go, lets have a nice DisplayLink to update our model with the screen refresh.
        let displayLink:CADisplayLink = CADisplayLink(target: self, selector: #selector(refreshModel))
        displayLink.add(to: .main, forMode:.common)
        loadTiles()
    }
    
    ///Start the game, make sure everything is set to go in here.
    func start() {
        pacManSprite = PacManSprite(xPos: 14,yPos: 17, tileSize: CGSize(width: self.tileSize, height: self.tileSize))
        ghostSprites.append(GhostSprite(xPos: 14, yPos: 11, tileSize: CGSize(width: self.tileSize, height: self.tileSize), ghostType: .Blinky))
        ghostSprites.append(GhostSprite(xPos: 12, yPos: 14, tileSize: CGSize(width: self.tileSize, height: self.tileSize), ghostType: .Clyde))
        ghostSprites.append(GhostSprite(xPos: 14, yPos: 14, tileSize: CGSize(width: self.tileSize, height: self.tileSize), ghostType: .Inky))
        ghostSprites.append(GhostSprite(xPos: 16, yPos: 14, tileSize: CGSize(width: self.tileSize, height: self.tileSize), ghostType: .Pinky))
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

    private func handleJoyPad() {
        guard gameState == .playing else { return }
        switch moveDirection {
        case .down:
            print("Down")
        case .left:
            print("Left")
        case .right:
            print("Right")
        case .up:
            print("Up")
        case .stop:
            print("Stop")
        }
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
            if let sprite {
                sprite.animate()
                sprite.move()
            }
        }
    }
    
}
