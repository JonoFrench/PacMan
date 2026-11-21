//
//  PacManApp.swift
//  PacMan
//
//  Created by Jonathan French on 21.11.26.
//

import SwiftUI

@main
struct PacManApp: App {
    @State private var manager = GameManager()
    var body: some Scene {
        WindowGroup {
            ContentView().environment(manager)
        }
    }
}
