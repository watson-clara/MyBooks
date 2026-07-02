//
//  LibraryViewModel.swift
//  MyBooks
//
//  Created by clarafication on 6/26/26.
//

import Foundation
import Observation

@Observable
final class LibraryViewModel {

    private let scanner = LibraryScanner()

    var books: [Book] = []

    func scan(folder: URL) {
        books = scanner.scan(folder: folder)
    }
}
