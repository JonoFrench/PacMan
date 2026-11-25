//
//  TopView.swift
//  PacMan
//
//  Created by Jonathan French on 21.11.26.
//

import SwiftUI

struct TopView: View {
    @Environment(GameManager.self) var manager
    @Environment(\.layoutMetrics) private var metrics
    var body: some View {

        VStack {
            Spacer()
            Spacer()
            HStack(spacing: 0) {

                VStack {
                    Text("1Up")
                    Text(String(format: "%06d", manager.score))
                }
                .frame(maxWidth: .infinity)

                VStack {
                    Text("High Score")
                    Text(String(format: "%06d", manager.hiscore))
                 }
                .frame(maxWidth: .infinity)

                VStack {
                    Text("2Up")
                    Text("000000")
                }
                .frame(maxWidth: .infinity)
            }
            .font(.custom("Emulogic", size: metrics.isPad ? 24 : 12))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
    }
}

#Preview {
    TopView()
}
