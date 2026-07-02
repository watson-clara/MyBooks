//
//  LibraryScanner.swift
//  MyBooks
//
//  Created by clarafication on 6/26/26.
//

import Foundation

final class LibraryScanner {

    func scan(folder: URL) -> [Book] {
        let fileManager = FileManager.default

        guard let enumerator = fileManager.enumerator(
            at: folder,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var books: [Book] = []

        for case let fileURL as URL in enumerator {
            guard fileURL.pathExtension.lowercased() == "pdf" else {
                continue
            }

            books.append(Book(url: fileURL))
        }

        return books.sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }
}
