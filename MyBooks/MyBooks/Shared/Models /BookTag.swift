//
//  BookTag.swift
//  MyBooks
//
//  Created by clarafication on 6/29/26.
//

import Foundation
import SwiftData

@Model
final class BookTag {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var name: String
    var colorHex: String

    init(name: String, colorHex: String = "#007AFF") {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
    }
}
