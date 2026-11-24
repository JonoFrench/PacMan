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
    
    let blinky = GhostSprite(xPos: 14, yPos: 11, tileSize: CGSize(width: 30, height: 30), ghostType: .Blinky)
    let clyde = GhostSprite(xPos: 12, yPos: 14, tileSize: CGSize(width: 30, height: 30), ghostType: .Clyde)
    let inky = GhostSprite(xPos: 14, yPos: 14, tileSize: CGSize(width: 30, height: 30), ghostType: .Inky)
    let pinky = GhostSprite(xPos: 16, yPos: 14, tileSize: CGSize(width: 30, height: 30), ghostType: .Pinky)
    
    var body: some View {
        //        ZStack {
        VStack(spacing: 0) {
            TopView()
                .frame(width:manager.metrics?.width,height: 100)
            Spacer()
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
            Spacer()
            Text("Character / Nickname")
                .font(.custom("Emulogic", size: 12))
                .foregroundStyle(Color.gray)
                .multilineTextAlignment(.center)
            Spacer()
            VStack(alignment: .leading, spacing: 8) {

                HStack {
                    staticGhostView(ghost: blinky)
                        .frame(width: 30, height: 30)

                    Text("- SHADOW \"BLINKY\"")
                        .foregroundStyle(.red)
                }

                HStack {
                    staticGhostView(ghost: pinky)
                        .frame(width: 30, height: 30)

                    Text("- SPEEDY \"PINKY\"")
                        .foregroundStyle(.pink)
                }

                HStack {
                    staticGhostView(ghost: inky)
                        .frame(width: 30, height: 30)

                    Text("- BASHFUL \"INKY\"")
                        .foregroundStyle(.cyan)
                }

                HStack {
                    staticGhostView(ghost: clyde)
                        .frame(width: 30, height: 30)

                    Text("- POKEY \"CLYDE\"")
                        .foregroundStyle(.orange)
                }
            }
            .font(.custom("Emulogic", size: 12))
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
            Text("(c) Namco 1980")
                .font(.custom("Emulogic", size: 12))
                .foregroundStyle(Color.pink)
                .multilineTextAlignment(.center)
            Spacer()
            
            Button(action: {
                manager.reset()
            }) {
                Text("Play")
                    .font(.custom("Emulogic", size: 12))
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Spacer()
        }.frame(width: metrics.width, height: metrics.height)
            .onAppear{
            }
    }
}

#Preview {
    IntroView()
}
