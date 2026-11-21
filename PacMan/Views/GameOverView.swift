//
//  GameOverView.swift
//  PacMan
//
//  Created by Jonathan French on 26.04.26.
//

import SwiftUI

struct GameOverView: View {
    @Environment(GameManager.self) var manager
    @Environment(\.layoutMetrics) private var metrics
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                Text(GameConstants.Text.GameOver)
                    .font(.custom("Menlo", size: metrics.scaledFont(GameConstants.TextSize.GameOverHead)))
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
        }.frame(width: metrics.width, height: metrics.height)
    }
}

#Preview {
    GameOverView()
}
