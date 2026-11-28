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
    @State private var visibleItems = 0
    @State private var showNextAnimation = false
    
    @State var blinky = GhostSprite(xPos: 14, yPos: 11, tileSize: CGSize(width: 30, height: 30), gameSpeed: 0.0, ghostType: .Blinky)
    @State var clyde = GhostSprite(xPos: 12, yPos: 14, tileSize: CGSize(width: 30, height: 30), gameSpeed: 0.0,ghostType: .Clyde)
    @State var inky = GhostSprite(xPos: 14, yPos: 14, tileSize: CGSize(width: 30, height: 30), gameSpeed: 0.0,ghostType: .Inky)
    @State var pinky = GhostSprite(xPos: 16, yPos: 14, tileSize: CGSize(width: 30, height: 30), gameSpeed: 0.0,ghostType: .Pinky)
    @State private var introTask: Task<Void, Never>?
    
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
                .font(.custom("Emulogic", size: metrics.isPad ? 24 : 12))
                .foregroundStyle(Color.gray)
                .multilineTextAlignment(.center)
            Spacer()
            VStack(alignment: .leading, spacing: 8) {
                
                HStack {
                    staticGhostView(ghost: blinky)
                        .frame(width: metrics.isPad ? 60 : 30, height: metrics.isPad ? 60 : 30)
                        .opacity(visibleItems >= 1 ? 1 : 0)
                    Text("- SHADOW ")
                        .foregroundStyle(.blinky)
                        .opacity(visibleItems >= 2 ? 1 : 0)
                    Text("\"BLINKY\"")
                        .foregroundStyle(.blinky)
                        .opacity(visibleItems >= 3 ? 1 : 0)
                }
                
                HStack {
                    staticGhostView(ghost: pinky)
                        .frame(width: metrics.isPad ? 60 : 30, height: metrics.isPad ? 60 : 30)
                        .opacity(visibleItems >= 4 ? 1 : 0)
                    Text("- SPEEDY ")
                        .foregroundStyle(.pinky)
                        .opacity(visibleItems >= 5 ? 1 : 0)
                    Text("\"PINKY\"")
                        .foregroundStyle(.pinky)
                        .opacity(visibleItems >= 6 ? 1 : 0)
                }
                
                HStack {
                    staticGhostView(ghost: inky)
                        .frame(width: metrics.isPad ? 60 : 30, height: metrics.isPad ? 60 : 30)
                       .opacity(visibleItems >= 7 ? 1 : 0)
                    Text("- BASHFUL ")
                        .foregroundStyle(.inky)
                        .opacity(visibleItems >= 8 ? 1 : 0)
                    Text("\"INKY\"")
                        .foregroundStyle(.inky)
                        .opacity(visibleItems >= 9 ? 1 : 0)
                }
                
                HStack {
                    staticGhostView(ghost: clyde)
                        .frame(width: metrics.isPad ? 60 : 30, height: metrics.isPad ? 60 : 30)
                        .opacity(visibleItems >= 10 ? 1 : 0)
                    Text("- POKEY ")
                        .foregroundStyle(.pokey)
                        .opacity(visibleItems >= 11 ? 1 : 0)
                    Text("\"CLYDE\"")
                        .foregroundStyle(.pokey)
                        .opacity(visibleItems >= 12 ? 1 : 0)
                }
            }
            .font(.custom("Emulogic", size: metrics.isPad ? 24 : 12))
            
            Spacer()
            VStack {
                HStack {
                    TileView(tile: 45)
                        .opacity(visibleItems >= 13 ? 1 : 0)
                    Text("10 pts")
                        .font(.custom("Emulogic", size: metrics.isPad ? 24 : 12))
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.center)
                        .opacity(visibleItems >= 13 ? 1 : 0)
                }
                HStack {
                    TileView(tile: 47)
                        .opacity(visibleItems >= 13 ? 1 : 0)
                    Text("50 pts")
                        .font(.custom("Emulogic", size: metrics.isPad ? 24 : 12))
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.center)
                        .opacity(visibleItems >= 13 ? 1 : 0)
                }
            }
            Spacer()
            Text("(c) Namco 1980")
                .font(.custom("Emulogic", size: metrics.isPad ? 24 : 12))
                .foregroundStyle(Color.pink)
                .multilineTextAlignment(.center)
            Spacer()
            
            Button(action: {
                introTask?.cancel()
                introTask = nil
                manager.reset()
            }) {
                Text("Play")
                    .font(.custom("Emulogic", size: metrics.isPad ? 24 : 12))
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Spacer()
        }.frame(width: metrics.width, height: metrics.height)
            .task {
                introTask = Task {
                for i in 1...13 {
                    try? await Task.sleep(for: .seconds(0.75))
                    
                    withAnimation(.easeIn(duration: 0.4)) {
                        visibleItems = i
                    }
                }
                // First sequence has finished
                withAnimation(.easeInOut(duration: 0.5)) {
                    setPacManAnimation()
                    showNextAnimation = true
                }
            }
        }
            .onAppear{
                setSprites()
                visibleItems = 1
                manager.introAnimation = false
                manager.introDot = false
            }
        if let pacman = manager.pacManSprite {
            if manager.introDot {
                TileView2(tile: 47).position(CGPoint(x: 50, y: pacman.position.y))
            }
           if !manager.pauseAction {
                PacManSpriteView(pacMan: pacman).zIndex(8)
            }
            ForEach(manager.ghostSprites, id: \.id) { ghost in
                if manager.pauseAction && ghost.ghostState == .dead {
                    GhostScoreView().position(pacman.position).zIndex(10)
                } else if ghost.ghostState != .dead {
                    GhostView(ghost: ghost).zIndex(6)
                }
            }
        }
    }
    
    func setPacManAnimation() {
        guard manager.gameState == .intro else { return }
        manager.introSprites()
        manager.introAnimation = true
    }
    
    func setSprites(){
        blinky = GhostSprite(xPos: 14, yPos: 11, tileSize: CGSize(width: metrics.isPad ? 60 : 30, height: metrics.isPad ? 60 : 30), gameSpeed: 0.0, ghostType: .Blinky)
        clyde = GhostSprite(xPos: 12, yPos: 14, tileSize: CGSize(width: metrics.isPad ? 60 : 30, height: metrics.isPad ? 60 : 30), gameSpeed: 0.0,ghostType: .Clyde)
        inky = GhostSprite(xPos: 14, yPos: 14, tileSize: CGSize(width: metrics.isPad ? 60 : 30, height: metrics.isPad ? 60 : 30), gameSpeed: 0.0,ghostType: .Inky)
        pinky = GhostSprite(xPos: 16, yPos: 14, tileSize: CGSize(width: metrics.isPad ? 60 : 30, height: metrics.isPad ? 60 : 30), gameSpeed: 0.0,ghostType: .Pinky)
        manager.ghostSprites.removeAll()
        manager.pacManSprite = nil

    }
}

#Preview {
    IntroView()
}
