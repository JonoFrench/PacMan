//
//  PacManSprite.swift
//  PacMan
//
//  Created by Jonathan French on 21.11.26.
//

import Foundation
import SwiftUI

final class PacManSprite:SwiftUISprite,Moveable,Animatable {

    var deadFrames: [UIImage] = []
    var leftFrames: [UIImage] = []
    var rightFrames: [UIImage] = []
    var downFrames: [UIImage] = []
    var upFrames: [UIImage] = []
    var lastDirection:Direction = .stop
    var lifeFrame:UIImage = UIImage()
    var caught = false
    
    init(xPos:Int, yPos:Int,tileSize:CGSize,gameSpeed:CGFloat) {
        super.init(xPos:xPos, yPos:yPos, frameSize:tileSize, gameSpeed: gameSpeed)
        
        setImages()
        animationSpeed = GameConstants.Animation.Sprite
        currentFrame = rightFrames[1]
        direction = .stop
        lifeFrame = leftFrames[1]
        speedMultiplier = 0.8
    }
    
    func move(deltaTime dt: CGFloat) {
        guard direction != .stop  else {return}
        let md = gameSpeed * speedMultiplier * dt

        print("delta time \(dt) movedistance \(md) gameSpeed \(gameSpeed) speedMultiplier \(speedMultiplier)")
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
    
    func align(for direction: Direction) {

        let tileWidth = frameSize.width
        let tileHeight = frameSize.height

        switch direction {

        case .up, .down:
            let x = (floor(position.x / tileWidth) + 0.5) * tileWidth
            position.x = x

        case .left, .right:
            let y = (floor(position.y / tileHeight) + 0.5) * tileHeight
            position.y = y

        case .stop:
            break
        }
    }
    
    func align2(for direction: Direction) {
        let tileWidth = frameSize.width
        let tileHeight = frameSize.height

        switch direction {
        case .up, .down:
            position.x = ((position.x / tileWidth - 0.5).rounded() + 0.5) * tileWidth

        case .left, .right:
            position.y = ((position.y / tileHeight - 0.5).rounded() + 0.5) * tileHeight

        case .stop:
            break
        }
    }
    
    func isAligned(for direction: Direction) -> Bool {

        let tileWidth = frameSize.width
        let tileHeight = frameSize.height

        let centreX = (floor(position.x / tileWidth) + 0.5) * tileWidth
        let centreY = (floor(position.y / tileHeight) + 0.5) * tileHeight

//        let tolerance = moveDistance * 100 * 0.02
        let tolerance = 100 * 0.02

        switch direction {

        case .up, .down:
            return abs(position.x - centreX) <= tolerance

        case .left, .right:
            return abs(position.y - centreY) <= tolerance

        case .stop:
            return false
        }
    }
    
    func setMoveSpeed(speed:CGFloat) {
        speedMultiplier = speed
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

            if caught {
                animateDead()
                return
            }
            var aniDir = lastDirection
            if direction != .stop {
                lastDirection = direction
                aniDir = lastDirection
            }
            animateCounter = 0
            if aniDir == .right {
                currentFrame = rightFrames[currentAnimationFrame]
            } else if aniDir == .left {
                currentFrame = leftFrames[currentAnimationFrame]
            } else if aniDir == .up {
                currentFrame = upFrames[currentAnimationFrame]
            } else if aniDir == .down {
                currentFrame = downFrames[currentAnimationFrame]
            }
            currentAnimationFrame += 1
             ///Loop back around
             if currentAnimationFrame == 3 {
                 currentAnimationFrame = 0
             }

        }
    }
    func animateDead() {
        currentFrame = deadFrames[currentAnimationFrame]
        currentAnimationFrame += 1
        if currentAnimationFrame == 11 {
            currentAnimationFrame = 10
        }

    }

    func setImages() {
        for x in 0..<3 {
            rightFrames.append(getTile(name: "PacMan", xPos: x,yPos: 0,width: 16,height: 16)!)
        }
        for x in 0..<3 {
            leftFrames.append(getTile(name: "PacMan", xPos: x,yPos: 1,width: 16,height: 16)!)
        }
        for x in 0..<3 {
            upFrames.append(getTile(name: "PacMan", xPos: x,yPos: 2,width: 16,height: 16)!)
        }
        for x in 0..<3 {
            downFrames.append(getTile(name: "PacMan", xPos: x,yPos: 3,width: 16,height: 16)!)
        }
        for x in 0..<11 {
            deadFrames.append(getTile(name: "DeadPacMan", xPos: x,width: 16,height: 16)!)
        }
    }
    
}


