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
            ForEach(Array(manager.fruitCollected.suffix(6).enumerated()), id: \.offset) { _, fruit in
                Image(uiImage: manager.fruit[fruit.rawValue])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width:manager.metrics!.isPad ? 48 : 24, height:manager.metrics!.isPad ? 48 : 24)
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
            .frame(width:manager.metrics!.isPad ? 48 : 24, height:manager.metrics!.isPad ? 48 : 24)
    }
}

struct GhostScoreView: View {
    @Environment(GameManager.self) var manager
    var body: some View {
        Image(uiImage: manager.ghostScores[manager.ghostCaught])
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width:manager.metrics!.isPad ? 48 : 24, height:manager.metrics!.isPad ? 48 : 24)
    }
}

struct FruitScoreView: View {
    @Environment(GameManager.self) var manager
    var body: some View {
        Image(uiImage: manager.ghostScores[manager.ghostCaught])
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width:manager.metrics!.isPad ? 48 : 24, height:manager.metrics!.isPad ? 48 : 24)
    }
}

#Preview {
    LivesView()
}
