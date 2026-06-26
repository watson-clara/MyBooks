//
//  LibraryFolderManager.swift
//  MyBooks
//
//  Created by clarafication on 6/26/26.
//

import Foundation

final class LibraryFolderManager {

    private let bookmarkKey = "libraryFolderBookmark"

    func saveLibraryFolder(_ url: URL) throws {
        let bookmarkData = try url.bookmarkData(
            options: [],
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )

        UserDefaults.standard.set(bookmarkData, forKey: bookmarkKey)
    }

    func loadLibraryFolder() -> URL? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: bookmarkKey) else {
            return nil
        }

        var isStale = false

        do {
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: [],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )

            if isStale {
                clearLibraryFolder()
                return nil
            }

            return url
        } catch {
            clearLibraryFolder()
            return nil
        }
    }

    func clearLibraryFolder() {
        UserDefaults.standard.removeObject(forKey: bookmarkKey)
    }
}
