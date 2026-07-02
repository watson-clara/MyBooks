//
//  AnnotationCategory.swift
//  MyBooks
//
//  Created by clarafication on 7/1/26.
//

import Foundation
import SwiftData

@Model
final class AnnotationCategory {

    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var name: String

    var colorHex: String
    var sortOrder: Int

    init(
        name: String,
        colorHex: String = "#FFD60A",
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.sortOrder = sortOrder
    }
}
