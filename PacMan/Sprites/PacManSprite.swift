//
//  PacManSprite.swift
//  PacMan
//
//  Created by Jonathan French on 21.11.26.
//

import Foundation

final class PacManSprite:SwiftUISprite,Moveable,Animatable {

    init(xPos:Int, yPos:Int,tileSize:CGSize) {
        super.init(xPos:xPos, yPos:yPos, frameSize:tileSize)
        
        setImages()
        animationSpeed = GameConstants.Animation.Sprite
        moveSpeed = GameConstants.Speed.Sprite
        moveDistance = GameConstants.Distance.Sprite
        currentFrame = frames[1]
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
        for y in 0..<3 {
            for x in 0..<3 {
                frames.append(getTile(name: "PacMan", xPos: x,yPos: y,width: 16,height: 16)!)
                }
            }
    }
}


