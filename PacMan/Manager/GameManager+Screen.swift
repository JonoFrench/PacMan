//
//  GameManager+Screen.swift
//  PacMan
//
//  Created by Jonathan French on 21.11.26.
//

import Foundation
import SwiftUI

extension GameManager {
    
    
    func loadTiles() {
        for i in 0..<48 {
            tiles.append(getTile(name: "Tiles2", xPos: i,width: 8,height: 8)!)
            whiteTiles.append(getTile(name: "Tiles3", xPos: i,width: 8,height: 8)!)
        }

    }
    func loadFruit() {
        for i in 0..<8 {
            fruit.append(getTile(name: "Fruit", xPos: i,width: 16,height: 16)!)
        }
    }
    func loadScores() {
        for i in 0..<4 {
            ghostScores.append(getTile(name: "Scores", xPos: i,width: 16,height: 16)!)
        }
    }
    
    ///Get Image from sprite sheet - horizontal
    ///
    func getTile(name:String,xPos:Int,width:Int,height:Int) -> UIImage? {
        guard let image = UIImage(named: name) else { return nil }
        let rect = CGRect(x: xPos * width, y: 0, width: width, height: height)
        guard let cgImage = image.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

}
