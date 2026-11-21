//
//  ScreenView.swift
//  PacMan
//
//  Created by Jonathan French on 21.11.26.
//

import SwiftUI
import Observation

struct ScreenView: View {
    @Environment(GameManager.self) var manager
    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 0) {
            ForEach(0..<GameConstants.Screen.Height, id: \.self) { y in
                HStack(spacing: 0) {
                    ForEach(0..<GameConstants.Screen.Width, id: \.self) { x in
                            TileView(tile: manager.screenData[y][x])
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ScreenView()
}
