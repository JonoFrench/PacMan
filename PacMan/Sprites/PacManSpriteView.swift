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
                .frame(width: pacMan.frameSize.width, height: pacMan.frameSize.height)
                .position(pacMan.position)
                .allowsHitTesting(false)
        }.onAppear {
        }
    }
}

//#Preview {
//    @Previewable @Environment(\.layoutMetrics) var metrics
//    let sprite = PacManSprite(position: CGPoint(x: 0, y: 0),metrics: metrics)
//    PacManSpriteView(pacMan: sprite)
//}
