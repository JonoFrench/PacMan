//
//  IntroView2.swift
//  PacMan
//
//  Created by Jonathan French on 25.11.26.
//

import SwiftUI

struct IntroView2: View {
    @Environment(GameManager.self) var manager
    @Environment(\.layoutMetrics) private var metrics
    var body: some View {
        VStack(spacing: 0) {
            TopView()
                .frame(width:manager.metrics?.width,height: 100)
            ZStack {
                if let pacman = manager.pacManSprite {
                ScreenView()
                DotView()
                TextView(message: "GAME OVER!",colour: .red)
                    .position(CGPoint(x: manager.metrics!.centerX, y: manager.tileSize * 17.5))
                
                    
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
                
            }.frame(width:manager.metrics?.width,height: manager.tileSize * 31)
            HStack {
                LivesView()
                    .frame(maxWidth: .infinity, alignment: .leading)
                FruitCollectedView()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            Spacer()
            //ControlView()
        }.onAppear {
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(GameConstants.Delay.GameOver))
                manager.gameState = .intro
            }
        }
    }
}

#Preview {
    IntroView2()
}
