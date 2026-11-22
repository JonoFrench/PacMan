//
//  TileView.swift
//  PacMan
//
//  Created by Jonathan French on 21.11.26.
//

import SwiftUI

struct TileView: View {
    @Environment(GameManager.self) var manager
    @State private var isFlashing = false
    var tile:Int
    var body: some View {
        Image(uiImage: manager.tiles[tile])
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: manager.tileSize, height: manager.tileSize)
            .opacity(tile == 47 && isFlashing ? 0.2 : 1.0)
            .onAppear {
                if tile == 47 {
                    withAnimation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true)) {
                        isFlashing = true
                    }
                }
            }
    }
}
