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
                }else if manager.gameState == .playing {
                    GameView()
                }else if manager.gameState == .gameover {
                    GameOverView()
                }
            }.environment(\.layoutMetrics, metrics)
                .onAppear {
                    manager.metrics = metrics
                    manager.tileSize = metrics.width / CGFloat(GameConstants.Screen.Width)
                    print("tilesize \(manager.tileSize)")

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
