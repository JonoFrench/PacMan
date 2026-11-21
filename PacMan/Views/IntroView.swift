//
//  IntroView.swift
//  PacMan
//
//  Created by Jonathan French on 26.04.26.
//

import SwiftUI

struct IntroView: View {
    @Environment(GameManager.self) var manager
    @Environment(\.layoutMetrics) private var metrics
    let yesno: (Bool) -> String = { b in b ? "Yes" : "No" }
    var body: some View {
//        ZStack {
            VStack(spacing: 0) {
                TopView()
                    .frame(width:manager.metrics?.width,height: 100)
                Spacer()
                Text(GameConstants.Text.IntroHead)
                    .font(.custom("Emulogic", size: 12))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Spacer()
                Text("Character / Nickname")
                    .font(.custom("Emulogic", size: 12))
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
                Spacer()
                Text("-SHADOW  \"BLINKY\"")
                    .font(.custom("Emulogic", size: 12))
                    .foregroundStyle(Color.red)
                    .multilineTextAlignment(.center)
                Spacer()
                Text("-SPEEDY  \"PINKY\"")
                    .font(.custom("Emulogic", size: 12))
                    .foregroundStyle(Color.pink)
                    .multilineTextAlignment(.center)
                Spacer()
                Text("-BASHFUL  \"INKY\"")
                    .font(.custom("Emulogic", size: 12))
                    .foregroundStyle(Color.cyan)
                    .multilineTextAlignment(.center)
                Spacer()
                Text("-POKEY  \"CLYDE\"")
                    .font(.custom("Emulogic", size: 12))
                    .foregroundStyle(Color.orange)
                    .multilineTextAlignment(.center)
                Spacer()
                Text("10 pts")
                    .font(.custom("Emulogic", size: 12))
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
                Text("50 pts")
                    .font(.custom("Emulogic", size: 12))
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
                Spacer()
                Text("Namco 1980")
                    .font(.custom("Emulogic", size: 12))
                    .foregroundStyle(Color.pink)
                    .multilineTextAlignment(.center)
                Spacer()

                Button(action: {
                    manager.start()
                }) {
                    Text("Play")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Spacer()
        }.frame(width: metrics.width, height: metrics.height)
    }
}

#Preview {
    IntroView()
}
