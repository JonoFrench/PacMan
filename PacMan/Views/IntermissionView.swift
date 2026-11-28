//
//  IntermissionView.swift
//  PacMan
//
//  Created by Jonathan French on 24.11.26.
//

import SwiftUI

struct IntermissionView: View {
    @Environment(GameManager.self) var manager
    @Environment(\.layoutMetrics) private var metrics
    @ObservedObject var ghost:GhostSprite
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black)
                .frame(width:manager.metrics?.width,height: 100)
            ZStack {
                Rectangle()
                    .fill(Color.black)

                if let pacman = manager.pacManSprite {
                    PacManSpriteView(pacMan: pacman).zIndex(8)
                        switch manager.intermission {
                        case .two:
                            GhostView(ghost: ghost).zIndex(6)
                        case .five:
                            GhostView(ghost: ghost).zIndex(6)
                            ImageView(ghost:ghost).position(x:metrics.width / 2,y:ghost.position.y).zIndex(7)
                        case .nine:
                            if ghost.direction == .left {
                                GhostView(ghost: ghost).zIndex(6)
                                    .onChange(of: ghost.direction) { oldValue, newValue in
                                        print("Ghost direction:", oldValue, "->", newValue)
                                    }
                            } else {
                                DoubleGhostView(ghost: ghost).zIndex(6)            .position(ghost.position)
                            }
                        }
                    }
            }.frame(width:manager.metrics?.width,height: manager.tileSize * 31)
            
            HStack {
                FruitCollectedView()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .onAppear{
//            manager.setUp(intermission: manager.intermission)
        }
    }
}

