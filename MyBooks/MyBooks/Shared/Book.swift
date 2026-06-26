//
//  Book.swift
//  MyBooks
//
//  Created by clarafication on 6/26/26.
//


import Foundation
import SwiftData

@Model
final class Book {

    var title: String

    init(title: String) {
        self.title = title
    }

}
