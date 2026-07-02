//
//  CodableRect.swift
//  MyBooks
//
//  Created by clarafication on 7/1/26.
//

import Foundation
import CoreGraphics

struct CodableRect: Codable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double

    init(rect: CGRect) {
        self.x = rect.origin.x
        self.y = rect.origin.y
        self.width = rect.width
        self.height = rect.height
    }

    var rect: CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }
}
