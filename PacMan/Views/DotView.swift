//
//  ScreenView 2.swift
//  PacMan
//
//  Created by Jonathan French on 21.11.26.
//

import SwiftUI
import Observation

struct DotView: View {
    @Environment(GameManager.self) var manager
    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 0) {
                ForEach(0..<GameConstants.Screen.Height, id: \.self) { y in
                    let characters = Array(manager.workingMap[y])
                    HStack(spacing: 0) {
                        ForEach(0..<GameConstants.Screen.Width, id: \.self) { x in
                            if characters[x] == "o" {
                                TileView(tile: 45)
                            } else if characters[x] == "*" {
                                TileView2(tile: 47)
                            } else {
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .frame(width: manager.tileSize, height: manager.tileSize)

                            }
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
