//
//  Book.swift
//  MyBooks
//
//  Created by clarafication on 6/26/26.
//

import Foundation

struct Book: Identifiable, Hashable {

    let id: String
    let url: URL

    init(url: URL) {
        self.url = url
        self.id = url.path
    }

    var title: String {
        url.deletingPathExtension().lastPathComponent
    }
}
