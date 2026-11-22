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
                .frame(width: ghost.frameSize.width * 1.7, height: ghost.frameSize.height * 1.7)
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
