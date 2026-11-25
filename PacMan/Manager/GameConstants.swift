//
//  GameConstants.swift
//  PacMan
//
//  Created by Jonathan French on 26.04.26.
//

import Foundation
import CoreGraphics

public enum Ghosts:Int {
    case Blinky = 0, Pinky,Inky,Clyde
}

public enum JoyPad {
    case left,right,up,down,stop
}

public enum GameState {
    case intro,intro2,starting,starting2,playing,caught,nextlevel,intermission,gameover,highscore
}

public enum Direction {
    case left,right,up,down,stop
}

public enum Fruit:Int, CaseIterable {
    case cherry = 0,strawberry,peach,apple,grape,galaxian,bell,key
}
public enum GameConstants {
    
    public enum Game {
        public static let Lives = 3
        public static let BaseSpeed: CGFloat = 75.75757625
        public static let OriginalTileSize: CGFloat = 8
    }
    public enum Screen {
        public static let Width = 28
        public static let Height = 31
        public static let TunnelRow = 14
    }

    public enum Position {
        public static let shipY = 140.0
        public static let shortShipY = 100.0
    }
    
    public enum Time {
        public static let Sprite = 0.5
        public static let ShowFruit = 30
        public static let ShowScared = 30
    }
    ///Higher speed = slower
    public enum Speed {
        public static let PacMan = 100.0
        public static let Ghost = 80.0

    }
    
    public enum Animation {
        public static let Sprite = 8
    }

    public enum Size {
        public static let Sprite = CGSize(width: 50, height: 50)
    }
    
    public enum Text {
        public static let Start = "TAP TO START"
        public static let IntroHead = "Pac Man"
        public static let GameOver = "Game Over"
    }
    
    public enum TextSize {
        public static let Start:CGFloat = 14
        public static let IntroHead:CGFloat = 28
        public static let GameOverHead:CGFloat = 36
    }
    
    public enum Delay {
        public static let Start = 3.0
        public static let Start2 = 1.5
        public static let Caught = 3.5
        public static let GameOver = 5.0
    }
    
    public enum Score {
        public static let Spot = 50
        public static let Pill = 10
        public static let MinePoints = 75
    }
    
    public enum Sound {
        public static let effectsVolume:Float = 1.0
        public static let backgroundVolume:Float = 1.0
        public static let musicVolume:Float = 1.0
    }


}
