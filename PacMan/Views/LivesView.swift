//
//  LivesView.swift
//  PacMan
//
//  Created by Jonathan French on 22.11.26.
//

import SwiftUI

struct LivesView: View {
    @Environment(GameManager.self) var manager
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(0..<manager.lives, id: \.self) { _ in
                PacManLifeView()
            }
        }
    }
}

struct FruitCollectedView: View {
    @Environment(GameManager.self) var manager
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(0..<manager.fruitCollected.count, id: \.self) { fruit in
                Image(uiImage: manager.fruit[manager.fruitCollected[fruit].rawValue])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                
            }
        }
    }
}

struct FruitView: View {
    @Environment(GameManager.self) var manager
    let fruit:Fruit
    var body: some View {
        Image(uiImage: manager.fruit[fruit.rawValue])
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
    }
}

struct GhostScoreView: View {
    @Environment(GameManager.self) var manager
    var body: some View {
        Image(uiImage: manager.ghostScores[manager.ghostCaught])
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
    }
}
#Preview {
    LivesView()
}
