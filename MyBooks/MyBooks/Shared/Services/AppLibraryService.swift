//
//  AppLibraryService.swift
//  MyBooks
//
//  Created by clarafication on 6/29/26.
//

import Foundation

final class AppLibraryService {

    private let libraryFolderName = "MyBooksLibrary"

    func libraryFolderURL() throws -> URL {
        let documentsURL = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let libraryURL = documentsURL.appendingPathComponent(libraryFolderName, isDirectory: true)

        if !FileManager.default.fileExists(atPath: libraryURL.path) {
            try FileManager.default.createDirectory(
                at: libraryURL,
                withIntermediateDirectories: true
            )
        }

        return libraryURL
    }

    func importPDFs(from urls: [URL]) throws {
        let libraryURL = try libraryFolderURL()

        for sourceURL in urls {
            let didAccess = sourceURL.startAccessingSecurityScopedResource()

            defer {
                if didAccess {
                    sourceURL.stopAccessingSecurityScopedResource()
                }
            }

            let destinationURL = uniqueDestinationURL(
                for: sourceURL.lastPathComponent,
                in: libraryURL
            )

            try FileManager.default.copyItem(
                at: sourceURL,
                to: destinationURL
            )

            print("Imported PDF to:", destinationURL.path)
        }
    }
    
    func deletePDF(at url: URL) throws {
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }
    
    private func uniqueDestinationURL(for filename: String, in folder: URL) -> URL {
        let baseURL = folder.appendingPathComponent(filename)

        if !FileManager.default.fileExists(atPath: baseURL.path) {
            return baseURL
        }

        let name = (filename as NSString).deletingPathExtension
        let ext = (filename as NSString).pathExtension

        var counter = 1

        while true {
            let newName = "\(name) \(counter).\(ext)"
            let candidate = folder.appendingPathComponent(newName)

            if !FileManager.default.fileExists(atPath: candidate.path) {
                return candidate
            }

            counter += 1
        }
    }
}
