//
//  TileView.swift
//  PacMan
//
//  Created by Jonathan French on 21.11.26.
//

import SwiftUI

struct TileView: View {
    @Environment(GameManager.self) var manager
    var tile:Int
    var body: some View {
        Image(uiImage: manager.tiles[tile])
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: manager.tileSize, height: manager.tileSize)
    }
}
