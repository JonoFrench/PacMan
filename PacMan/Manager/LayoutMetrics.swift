//
//  LayoutMetrics.swift
//  PacMan
//
//  Created by Jonathan French on 26.04.26.
//

import Foundation
import SwiftUI

struct LayoutMetrics {
    let size: CGSize
    let safeArea: EdgeInsets

    let width: CGFloat
    let height: CGFloat
    let shortSide: CGFloat
    let longSide: CGFloat

    let centerX: CGFloat
    let centerY: CGFloat

    let isPad: Bool
    let isLandscape: Bool
    let isSmallPhone: Bool
    let isLargePhone: Bool

    let uiScale: CGFloat
    let fontScale: CGFloat
    let gameScale: CGFloat

    let topBarHeight: CGFloat
    let bottomBarHeight: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    
    init(size: CGSize, safeArea: EdgeInsets, idiom: UIUserInterfaceIdiom = UIDevice.current.userInterfaceIdiom) {
        self.size = size
        self.safeArea = safeArea

        self.width = size.width
        self.height = size.height
        self.centerX = width / 2
        self.centerY = height / 2
        self.shortSide = min(size.width, size.height)
        self.longSide = max(size.width, size.height)

        self.isPad = idiom == .pad
        self.isLandscape = size.width > size.height
        self.isSmallPhone = !isPad && shortSide <= 375
        self.isLargePhone = !isPad && shortSide >= 414
        
        let basePhoneWidth: CGFloat = 390
        let rawScale = shortSide / basePhoneWidth

        self.uiScale = min(max(rawScale, 0.92), 1.12)
        self.fontScale = min(max(rawScale, 0.94), 1.10)
        self.gameScale = min(max(rawScale, 0.90), 1.18)
        
        if isPad {
            self.topBarHeight = isLandscape ? 90 : 100
            self.bottomBarHeight = isLandscape ? 110 : 120
            self.horizontalPadding = 24
            self.verticalPadding = 16
        } else if isSmallPhone {
            self.topBarHeight = 58
            self.bottomBarHeight = 74
            self.horizontalPadding = 10
            self.verticalPadding = 6
        } else {
            self.topBarHeight = 68
            self.bottomBarHeight = 88
            self.horizontalPadding = 14
            self.verticalPadding = 8
        }
    }
}

private struct LayoutMetricsKey: EnvironmentKey {
    static let defaultValue = LayoutMetrics(
        size: CGSize(width: 390, height: 844),
        safeArea: EdgeInsets()
    )
}

extension EnvironmentValues {
    var layoutMetrics: LayoutMetrics {
        get { self[LayoutMetricsKey.self] }
        set { self[LayoutMetricsKey.self] = newValue }
    }
}

extension LayoutMetrics {
    func scaledFont(_ size: CGFloat) -> CGFloat {
        size * fontScale
    }
}
