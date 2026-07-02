//
//  LibraryFolderService.swift
//  MyBooks
//
//  Created by clarafication on 6/26/26.
//

import Foundation

final class LibraryFolderService {

    private let bookmarkKey = "libraryFolderBookmark"

    func saveLibraryFolder(_ url: URL) throws {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let bookmarkData = try url.bookmarkData(
            options: [.minimalBookmark],
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
            print("Failed to resolve library folder bookmark:", error)
            clearLibraryFolder()
            return nil
        }
    }

    func clearLibraryFolder() {
        UserDefaults.standard.removeObject(forKey: bookmarkKey)
    }
}

