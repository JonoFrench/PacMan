//
//  GameView.swift
//  PacMan
//
//  Created by Jonathan French on 21.11.26.
//

import SwiftUI

struct GameView: View {
    @Environment(GameManager.self) var manager
    var body: some View {
        VStack(spacing: 0) {
            TopView()
                .frame(width:manager.metrics?.width,height: 100)
            ZStack {
                if let pacman = manager.pacManSprite {
                    ScreenView()
                    DotView()
                    if manager.gameState == .starting {
                        TextView(message: "Player ONE",colour: .cyan)
                            .position(CGPoint(x: manager.metrics!.centerX, y: manager.tileSize * 11.5))
                        TextView(message: "READY!",colour: .yellow)
                            .position(CGPoint(x: manager.metrics!.centerX, y: manager.tileSize * 17.5))
                    }
                    if manager.gameState == .starting2 {
                        TextView(message: "READY!",colour: .yellow)
                            .position(CGPoint(x: manager.metrics!.centerX, y: manager.tileSize * 17.5))
                        PacManSpriteView(pacMan: pacman).zIndex(8)
                        ForEach(manager.ghostSprites, id: \.id) { ghost in
                            GhostView(ghost: ghost).zIndex(6)
                        }
                    }
                    if manager.gameState == .caught {
                        PacManSpriteView(pacMan: pacman).zIndex(8)

                    }
                    if manager.gameState == .playing {
                        
                        if manager.showFruit {
                            FruitView(fruit: manager.selectedFruit)
                                .position(CGPoint(x: manager.metrics!.centerX, y: manager.tileSize * 17.5))
                        }
                        
                        if !manager.pauseAction {
                            PacManSpriteView(pacMan: pacman).zIndex(8)
                        }
                        ForEach(manager.ghostSprites, id: \.id) { ghost in
                            if manager.pauseAction && ghost.ghostState == .dead {
                                GhostScoreView().position(pacman.position).zIndex(10)
                            } else {
                                GhostView(ghost: ghost).zIndex(6)
                            }
                        }
                    }
                }
            }.frame(width:manager.metrics?.width,height: manager.tileSize * 31)
            HStack {
                LivesView()
                    .frame(maxWidth: .infinity, alignment: .leading)
                FruitCollectedView()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            ControlView()
        }
    }
}

#Preview {
    GameView()
}
