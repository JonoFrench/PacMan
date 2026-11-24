//
//  TextView.swift
//  PacMan
//
//  Created by Jonathan French on 23.11.26.
//

import SwiftUI

struct TextView: View {
    var message = "Game Over"
    var colour:Color = .white
    var body: some View {
        Text(message)
            .font(.custom("Emulogic", size: 12))
            .foregroundStyle(colour)
            .multilineTextAlignment(.center)
    }
}

#Preview {
    TextView()
}
