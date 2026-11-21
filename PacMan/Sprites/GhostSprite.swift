//
//  GhostSprite.swift
//  PacMan
//
//  Created by Jonathan French on 21.11.26.
//

import Foundation

final class GhostSprite:SwiftUISprite,Moveable,Animatable {
    let ghost:Ghosts
    
    init(xPos:Int, yPos:Int,tileSize:CGSize, ghostType:Ghosts) {
        ghost = ghostType
        super.init(xPos:xPos, yPos:yPos, frameSize:tileSize)
        setImages()
        animationSpeed = GameConstants.Animation.Sprite
        moveSpeed = GameConstants.Speed.Sprite
        moveDistance = GameConstants.Distance.Sprite
        currentFrame = frames[0]
        direction = .right
    }
    
    func move() {
        moveCounter += 1
        if moveCounter == moveSpeed {
            moveCounter = 0
/// Here we now move our sprite. Each will have its own specific movement logic.
            if direction == .left {
                self.position.x -= moveDistance
                if self.position.x <= 0 {
                    direction = .right
                }
            } else if direction == .right {
                self.position.x += moveDistance
                if self.position.x >= 400 {
                    direction = .left
                }

            }
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
                currentFrame = frames[currentAnimationFrame]
               currentAnimationFrame += 1
                ///Loop back around
                if currentAnimationFrame == frames.count {
                    currentAnimationFrame = 0
                }
            } else if direction == .left {
                currentFrame = frames[currentAnimationFrame]
                currentAnimationFrame -= 1
                ///Loop back around
                if currentAnimationFrame == -1 {
                    currentAnimationFrame = frames.count - 1
                }
            }
        }
    }

    func setImages() {
        for i in 0..<4 {
            frames.append(getTile(name: "Ghosts", xPos: i,yPos: ghost.rawValue,width: 16,height: 16)!)
        }
    }
}


