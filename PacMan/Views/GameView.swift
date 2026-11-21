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
                ScreenView()
                DotView()
                if let pacman = manager.pacManSprite {
                    PacManSpriteView(pacMan: pacman)
                }
                ForEach(manager.ghostSprites, id: \.id) { ghost in
                    GhostView(ghost: ghost)
                }
            }.frame(width:manager.metrics?.width,height: manager.tileSize * 31)
            ControlView()
        }
    }
}

#Preview {
    GameView()
}
