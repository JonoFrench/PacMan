//
//  GhostView.swift
//  PacMan
//
//  Created by Jonathan French on 21.11.26.
//

import SwiftUI

struct GhostView: View {
    @ObservedObject var ghost:GhostSprite
    var body: some View {
        ZStack {
            Image(uiImage: ghost.currentFrame)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: ghost.frameSize.width * 1.8, height: ghost.frameSize.height * 1.8)
                .position(ghost.position)
                .allowsHitTesting(false)
        }.onAppear {
        }
    }
}
struct staticGhostView: View {
    var ghost:GhostSprite
    var body: some View {
        ZStack {
            Image(uiImage: ghost.currentFrame)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: ghost.frameSize.width, height: ghost.frameSize.height)
                .allowsHitTesting(false)
        }.onAppear {
        }
    }
}

struct DoubleGhostView: View {
    @Environment(\.layoutMetrics) private var metrics
    @ObservedObject var ghost:GhostSprite
    var body: some View {
        ZStack {
//            HStack(spacing: -(ghost.frameSize.width / 2)) {
                HStack(spacing: 0) {
                Image(uiImage: ghost.currentFrame)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: ghost.frameSize.width * 1.8, height: ghost.frameSize.height * 1.8)
                Image(uiImage: ghost.secondFrame)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: ghost.frameSize.width * 1.8, height: ghost.frameSize.height * 1.8)
            }
            .allowsHitTesting(false)
            .frame(width: (ghost.frameSize.width * 1.8) * 2, height: ghost.frameSize.height * 1.8)
        }.onAppear {
        }
    }
}
