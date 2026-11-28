//
//  ContentView.swift
//  PacMan
//
//  Created by Jonathan French on 26.04.26.
//

import SwiftUI

struct ContentView: View {
    @Environment(GameManager.self) var manager
    var body: some View {
        GeometryReader { geo in
            let metrics = LayoutMetrics(size: geo.size, safeArea: geo.safeAreaInsets)
            ZStack {
                if manager.gameState == .intro {
                    IntroView()
                } else if manager.gameState == .intro2 {
                    IntroView2()
                } else if manager.gameState == .intermission {
                    IntermissionView(ghost: manager.ghostSprites[0])
                } else {
                    GameView()
                }
            }.environment(\.layoutMetrics, metrics)
                .onAppear {
                    manager.metrics = metrics
                    manager.tileSize = metrics.width / CGFloat(GameConstants.Screen.Width)
                    manager.gameSpeed = GameConstants.Game.BaseSpeed * (manager.tileSize / GameConstants.Game.OriginalTileSize)

                    print("tilesize \(manager.tileSize) gameSpeed \(manager.gameSpeed)")

                }
        }.background(Color(.black))
            .ignoresSafeArea()
            .statusBar(hidden: true)
    }
}

#Preview {
    @Previewable @State var manager = GameManager()
    ContentView().environment(manager)
}
