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
    case intro,playing,gameover,highscore
}

public enum Direction {
    case left,right,up,down,stop
}

public enum GameConstants {
    
    public enum Game {
        public static let Lives = 3
    }
    public enum Screen {
        public static let Width = 28
        public static let Height = 31
    }

    public enum Position {
        public static let shipY = 140.0
        public static let shortShipY = 100.0
    }
    
    public enum Time {
        public static let Sprite = 0.5
    }
    ///Higher speed = slower
    public enum Speed {
        public static let Sprite = 2
    }
    
    public enum Animation {
        public static let Sprite = 2
    }

    public enum Distance {
        public static let Sprite = 1.0
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
        public static let Start = 3.5
        public static let GameOver = 5.0
    }
    
    public enum Score {
        public static let Sprite = 100
        public static let AsteroidPoints = 150
        public static let MinePoints = 75
    }
}
