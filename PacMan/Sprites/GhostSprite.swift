//
//  GhostSprite.swift
//  PacMan
//
//  Created by Jonathan French on 21.11.26.
//

import Foundation
import SwiftUI
import Combine

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
    var inter5Frames: [UIImage] = []
    var inter9Frames: [UIImage] = []
    var secondFrame:UIImage = UIImage()

    var ghostState:GhostState = .leavingHouse {
        didSet {
            animateCounter = 0
            currentAnimationFrame = 0
        }
    }
    var houseTimer: CGFloat = 0
    let houseWaitDuration: CGFloat = 3.0
    var flashing = false
    var flash = false

    init(xPos:Int, yPos:Int,tileSize:CGSize,gameSpeed:CGFloat, ghostType:Ghosts) {
        ghost = ghostType
        super.init(xPos:xPos, yPos:yPos, frameSize:tileSize, gameSpeed: gameSpeed)
        setImages()
        animationSpeed = GameConstants.Animation.Sprite
        currentFrame = rightFrames[0]
        direction = .right
        secondFrame = inter5Frames[9]
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
    
    func animateFive(deltaTime dt: CGFloat){
        animateCounter += 1
        if animateCounter == 8 {
            print("animateFive \(currentAnimationFrame)")
            animateCounter = 0
            if currentAnimationFrame < 4 {
                move(deltaTime: dt)
                currentFrame = leftFrames[currentAnimationFrame % 2]
                secondFrame = inter5Frames[currentAnimationFrame]
            }
            if currentAnimationFrame == 4 {
                currentFrame = inter5Frames[5]
                secondFrame = inter5Frames[4]
            }
            if currentAnimationFrame == 6 {
                currentFrame = inter5Frames[6]
                secondFrame = inter5Frames[4]
                animateCounter = -1
            }
            currentAnimationFrame += 1
        }
    }
    func animateNine(){
        animateCounter += 1
        if animateCounter == animationSpeed {

            animateCounter = 0
            if direction == .left {
                currentFrame = inter5Frames[currentAnimationFrame + 7]

            } else {
                let animFrame = currentAnimationFrame * 2
                currentFrame = inter9Frames[animFrame]
                secondFrame = inter9Frames[animFrame + 1]
            }
            currentAnimationFrame += 1

            if currentAnimationFrame == 2 {
                currentAnimationFrame = 0
            }

        }
    }

    
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
        inter5Frames.removeAll()
        inter9Frames.removeAll()
        
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
        
        for y in 0..<2 {
            for x in 0..<5 {
                inter5Frames.append(getTile(name: "Intermission", xPos: x,yPos: y,width: 16,height: 16)!)
                inter9Frames.append(getTile(name: "Intermission", xPos: x,yPos: y + 2,width: 16,height: 16)!)
            }
        }
    }
}


