//
//  PacManSpriteView.swift
//  PacMan
//
//  Created by Jonathan French on 26.04.26.
//

import SwiftUI

struct PacManSpriteView: View {
    @Environment(\.layoutMetrics) private var metrics
    @ObservedObject var pacMan:PacManSprite
    var body: some View {
        ZStack {
            Image(uiImage: pacMan.currentFrame)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: pacMan.frameSize.width * 1.8, height: pacMan.frameSize.height * 1.8)
                .position(pacMan.position)
                .allowsHitTesting(false)
        }.onAppear {
        }
    }
}

struct PacManLifeView: View {
    @Environment(GameManager.self) var manager
    var body: some View {
        ZStack {
            Image(uiImage: manager.pacManSprite!.lifeFrame)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:manager.metrics!.isPad ? 48 : 24, height:manager.metrics!.isPad ? 48 : 24)
        }
    }
}
