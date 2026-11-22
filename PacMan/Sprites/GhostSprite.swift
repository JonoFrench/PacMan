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
}

final class GhostSprite:SwiftUISprite,Moveable,Animatable {
    let ghost:Ghosts
    var lastDecisionColumn = -1
    var lastDecisionRow = -1
    var leftFrames: [UIImage] = []
    var rightFrames: [UIImage] = []
    var downFrames: [UIImage] = []
    var upFrames: [UIImage] = []
    var ghostState:GhostState = .leavingHouse

    init(xPos:Int, yPos:Int,tileSize:CGSize, ghostType:Ghosts) {
        ghost = ghostType
        super.init(xPos:xPos, yPos:yPos, frameSize:tileSize)
        setImages()
        animationSpeed = GameConstants.Animation.Sprite
        moveSpeed = GameConstants.Speed.Sprite
        moveDistance = GameConstants.Distance.Sprite
        currentFrame = rightFrames[0]
        direction = .right
    }
    
    func move(deltaTime dt: CGFloat) {
        guard direction != .stop  else {return}
        let md = moveDistance * 80 * dt
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
    
    func setMoveSpeed(speed:Int) {
        moveCounter = 0
        moveSpeed = speed
    }
    
    func setMoveDistance(distance:Double) {
        moveDistance = distance
    }

    func setAnimateSpeed(speed:Int) {
        animateCounter = 0
        currentAnimationFrame = 0
        animationSpeed = speed
    }
    
    func animate() {
        animateCounter += 1
        if animateCounter == animationSpeed {
            animateCounter = 0
            if direction == .right {
                currentFrame = rightFrames[currentAnimationFrame]
            } else if direction == .left {
                currentFrame = leftFrames[currentAnimationFrame]
            } else if direction == .up {
                currentFrame = upFrames[currentAnimationFrame]
            } else if direction == .down {
                currentFrame = downFrames[currentAnimationFrame]
            }
            currentAnimationFrame += 1
             ///Loop back around
             if currentAnimationFrame == 2 {
                 currentAnimationFrame = 0
             }

        }
    }
//    func animate() {
//        animateCounter += 1
//        if animateCounter == animationSpeed {
//            animateCounter = 0
//            currentFrame = frames[currentAnimationFrame]
//           currentAnimationFrame += 1
//            ///Loop back around
//            if currentAnimationFrame == frames.count {
//                currentAnimationFrame = 0
//            }
//
//            
//            if direction == .right {
//            } else if direction == .left {
//                currentFrame = frames[currentAnimationFrame]
//                currentAnimationFrame -= 1
//                ///Loop back around
//                if currentAnimationFrame == -1 {
//                    currentAnimationFrame = frames.count - 1
//                }
//            } else if direction == .left {
//                currentFrame = frames[currentAnimationFrame]
//                currentAnimationFrame -= 1
//                ///Loop back around
//                if currentAnimationFrame == -1 {
//                    currentAnimationFrame = frames.count - 1
//                }
//            }
//        }
//    }

    func setImages() {
        for i in 0..<2 {
            rightFrames.append(getTile(name: "Ghosts", xPos: i,yPos: ghost.rawValue,width: 16,height: 16)!)
            leftFrames.append(getTile(name: "Ghosts", xPos: i + 2,yPos: ghost.rawValue,width: 16,height: 16)!)
            upFrames.append(getTile(name: "Ghosts", xPos: i + 4,yPos: ghost.rawValue,width: 16,height: 16)!)
            downFrames.append(getTile(name: "Ghosts", xPos: i + 6,yPos: ghost.rawValue,width: 16,height: 16)!)


        }
    }
}


