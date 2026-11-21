//
//  TopView.swift
//  PacMan
//
//  Created by Jonathan French on 21.11.26.
//

import SwiftUI

struct TopView: View {

    var body: some View {

        VStack {
            Spacer()
Spacer()
            HStack(spacing: 0) {

                VStack {
                    Text("1Up")
                    Text("000000")
                }
                .frame(maxWidth: .infinity)

                VStack {
                    Text("High Score")
                    Text("000000")
                }
                .frame(maxWidth: .infinity)

                VStack {
                    Text("2Up")
                    Text("000000")
                }
                .frame(maxWidth: .infinity)
            }
            .font(.custom("Emulogic", size: 12))
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
