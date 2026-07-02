//
//  Category.swift
//  MyBooks
//
//  Created by clarafication on 6/29/26.
//

import Foundation
import SwiftData

@Model
final class BookCategory {

    @Attribute(.unique)
    var id: UUID

    @Attribute(.unique)
    var name: String

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}
