//
//  TextView.swift
//  PacMan
//
//  Created by Jonathan French on 23.11.26.
//

import SwiftUI

struct TextView: View {
    @Environment(\.layoutMetrics) private var metrics
    var message = "Game Over"
    var colour:Color = .white
    var body: some View {
        Text(message)
            .font(.custom("Emulogic", size: metrics.isPad ? 24 : 12))
            .foregroundStyle(colour)
            .multilineTextAlignment(.center)
    }
}

#Preview {
    TextView()
}
