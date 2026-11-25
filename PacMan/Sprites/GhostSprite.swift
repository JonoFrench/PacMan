//
//  GhostSprite.swift
//  PacMan
//
//  Created by Jonathan French on 21.11.26.
//

import Foundation
import SwiftUI

enum GhostState {
    case leavingHouse
    case wandering
    case chasing
    case scared
    case dead
    case inHouse
}

final class GhostSprite:SwiftUISprite,Moveable,Animatable {
    let ghost:Ghosts
    var lastDecisionColumn = -1
    var lastDecisionRow = -1
    var leftFrames: [UIImage] = []
    var rightFrames: [UIImage] = []
    var downFrames: [UIImage] = []
    var upFrames: [UIImage] = []
    var scaredFrames: [UIImage] = []
    var deadFrames: [UIImage] = []
    var ghostState:GhostState = .leavingHouse {
        didSet {
            animateCounter = 0
            currentAnimationFrame = 0
        }
    }
    var houseTimer: CGFloat = 0
    let houseWaitDuration: CGFloat = 3.0
    var flashing = false
    
    init(xPos:Int, yPos:Int,tileSize:CGSize,gameSpeed:CGFloat, ghostType:Ghosts) {
        ghost = ghostType
        super.init(xPos:xPos, yPos:yPos, frameSize:tileSize, gameSpeed: gameSpeed)
        setImages()
        animationSpeed = GameConstants.Animation.Sprite
        currentFrame = rightFrames[0]
        direction = .right
    }
    
    func move(deltaTime dt: CGFloat) {
        guard direction != .stop  else {return}
        let md = gameSpeed * speedMultiplier * dt
        /// Here we now move our sprite. Each will have its own specific movement logic.
        if direction == .left {
            self.position.x -= md
        } else if direction == .right {
            self.position.x += md
        } else if direction == .up {
            self.position.y -= md
        } else if direction == .down {
            self.position.y += md
        }
    }

    func setAnimateSpeed(speed:Int) {
        animateCounter = 0
        currentAnimationFrame = 0
        animationSpeed = speed
    }
    
    var flash = false
    func animate() {
        animateCounter += 1
        if animateCounter == animationSpeed {
            
            animateCounter = 0
            if direction == .right {
                if ghostState == .scared {
                    currentFrame = scaredFrames[!flash ? currentAnimationFrame : currentAnimationFrame + 2]
                } else if ghostState == .dead {
                    currentFrame = deadFrames[0]
                } else {
                    currentFrame = rightFrames[currentAnimationFrame]
                }
            } else if direction == .left {
                if ghostState == .scared {
                    currentFrame = scaredFrames[!flash ? currentAnimationFrame : currentAnimationFrame + 2]
                } else if ghostState == .dead {
                    currentFrame = deadFrames[1]
                } else {
                    currentFrame = leftFrames[currentAnimationFrame]
                }
            } else if direction == .up {
                if ghostState == .scared {
                    currentFrame = scaredFrames[!flash ? currentAnimationFrame : currentAnimationFrame + 2]
                } else if ghostState == .dead {
                    currentFrame = deadFrames[2]
                } else {
                    currentFrame = upFrames[currentAnimationFrame]
                }
            } else if direction == .down {
                if ghostState == .scared {
                    currentFrame = scaredFrames[!flash ? currentAnimationFrame : currentAnimationFrame + 2]
                } else if ghostState == .dead {
                    currentFrame = deadFrames[3]
                } else {
                    currentFrame = downFrames[currentAnimationFrame]
                }
            }
            currentAnimationFrame += 1
             ///Loop back around
            if ghostState == .scared {
                if currentAnimationFrame == 2 {
                    currentAnimationFrame = 0
                    if flashing { flash.toggle() }
                }
            } else {
                if currentAnimationFrame == 2 {
                    currentAnimationFrame = 0
                }
            }
        }
    }


    func setImages() {
        rightFrames.removeAll()
        leftFrames.removeAll()
        upFrames.removeAll()
        downFrames.removeAll()
        scaredFrames.removeAll()
        deadFrames.removeAll()
        for i in 0..<2 {
            rightFrames.append(getTile(name: "Ghosts", xPos: i,yPos: ghost.rawValue,width: 16,height: 16)!)
            leftFrames.append(getTile(name: "Ghosts", xPos: i + 2,yPos: ghost.rawValue,width: 16,height: 16)!)
            upFrames.append(getTile(name: "Ghosts", xPos: i + 4,yPos: ghost.rawValue,width: 16,height: 16)!)
            downFrames.append(getTile(name: "Ghosts", xPos: i + 6,yPos: ghost.rawValue,width: 16,height: 16)!)
        }
        
        for i in 0..<4 {
            scaredFrames.append(getTile(name: "DeadGhosts", xPos: i,yPos: 0,width: 16,height: 16)!)
            deadFrames.append(getTile(name: "DeadGhosts", xPos: i,yPos: 1,width: 16,height: 16)!)
        }
    }
}


