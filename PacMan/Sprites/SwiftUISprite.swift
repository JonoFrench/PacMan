//
//  SwiftUISprite.swift
//  PacMan
//
//  Created by Jonathan French on 26.04.26.
//

import Foundation
import SwiftUI
import Combine

protocol Animatable {
    func animate()
    func setImages()
}

protocol Moveable {
    func move()
    func setImages()
}

class SwiftUISprite:ObservableObject {
///Lifecycle
    var id = UUID()
    var delete = false
//    var metrics:LayoutMetrics?

///Size, location and image.
    @Published
    var position = CGPoint()
    @Published
    var frameSize: CGSize = CGSize()
    @Published
    var currentFrame:UIImage = UIImage()

/// Animation
    var frames: [UIImage] = []
    var animateCounter: Int = 0
    var currentAnimationFrame: Int = 0
    var animationSpeed: Int = 0
///Movement
    var moveDistance:CGFloat = 0.0
    var moveCounter: Int = 0
    var moveSpeed: Int = 0
    var direction: Direction = .stop
    
    init(position:CGPoint, frameSize: CGSize) {
        self.frameSize = frameSize
        self.position = position
//        self.metrics = metrics
        animateCounter = 0
        moveCounter = 0
        currentAnimationFrame = 0
    }
    init(xPos:Int, yPos:Int, frameSize: CGSize) {
        self.frameSize = frameSize
        self.position = positionForTile(x: xPos, y: yPos)
        animateCounter = 0
        moveCounter = 0
        currentAnimationFrame = 0
    }

    ///Get Image from sprite sheet - horizontal
    ///
    func getTile(name:String,xPos:Int,width:Int,height:Int) -> UIImage? {
        guard let image = UIImage(named: name) else { return nil }
        let rect = CGRect(x: xPos * width, y: 0, width: width, height: height)
        guard let cgImage = image.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

    ///Get Image from sprite sheet - vertical
    ///
    func getTile(name:String,yPos:Int,width:Int,height:Int) -> UIImage? {
        guard let image = UIImage(named: name) else { return nil }
        let rect = CGRect(x: 0, y: yPos * height, width: width, height: height)
        guard let cgImage = image.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    ///Get Image from sprite sheet - pos
    ///
    func getTile(name:String,xPos:Int,yPos:Int,width:Int,height:Int) -> UIImage? {
        guard let image = UIImage(named: name) else { return nil }
        let rect = CGRect(x: xPos * width , y: yPos * height, width: width, height: height)
        guard let cgImage = image.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

    ///Collision Testing
    func circlesIntersect(center: CGPoint, diameter: CGFloat) -> Bool {
        let radius1 = diameter / 2
        let radius2 = self.frameSize.width / 2 / 2
        let distanceX = self.position.x - center.x
        let distanceY = self.position.y - center.y
        let distanceSquared = distanceX * distanceX + distanceY * distanceY
        let radiusSum = radius1 + radius2
        let radiusSumSquared = radiusSum * radiusSum
        return distanceSquared <= radiusSumSquared
    }

    func positionForTile(x: Int, y: Int) -> CGPoint {

        CGPoint(
            x: (CGFloat(x) + 0.5) * frameSize.width,
            y: (CGFloat(y) + 0.5) * frameSize.height
        )
    }
}
