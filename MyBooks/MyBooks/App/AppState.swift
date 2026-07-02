//
//  AppState.swift
//  MyBooks
//
//  Created by clarafication on 6/26/26.
//

import Foundation
import Observation

@Observable
final class AppState {

    var selectedSidebarItem: SidebarItem? = .library
    var selectedBook: Book?
    var libraryURL: URL?
    var searchText = ""
    var isScanning = false

    private let folderManager = LibraryFolderService()

    init() {
        libraryURL = folderManager.loadLibraryFolder()
    }

    func setLibraryFolder(_ url: URL) {
        do {
            try folderManager.saveLibraryFolder(url)
            libraryURL = url
        } catch {
            print("Failed to save library folder: \(error)")
        }
    }

    func clearLibraryFolder() {
        folderManager.clearLibraryFolder()
        libraryURL = nil
    }
}
