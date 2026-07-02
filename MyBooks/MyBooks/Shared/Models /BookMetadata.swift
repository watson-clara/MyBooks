//
//  BookMetadata.swift
//  MyBooks
//
//  Created by clarafication on 6/26/26.
//

import Foundation
import SwiftData

@Model
final class BookMetadata {

    @Attribute(.unique) var fileID: String

    var customTitle: String
    var author: String
    var category: BookCategory?
    var bookNotes: String
    var favorite: Bool

    var currentPage: Int
    var pageCount: Int

    var highlightsCount: Int
    var notesCount: Int
    var bookmarksCount: Int
    var inkCount: Int
    @Relationship
    var tags: [BookTag] = []

    
    init(fileID: String, defaultTitle: String, pageCount: Int = 0) {
        self.fileID = fileID
        self.customTitle = defaultTitle
        self.author = ""
        self.category = nil
        self.bookNotes = ""
        self.favorite = false

        self.currentPage = 0
        self.pageCount = pageCount

        self.highlightsCount = 0
        self.notesCount = 0
        self.bookmarksCount = 0
        self.inkCount = 0
        
        self.tags = []
    }

    var displayTitle: String {
        customTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? "Untitled"
        : customTitle
    }

    var displayAuthor: String {
        author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? "Unknown Author"
        : author
    }

    var progress: Double {
        guard pageCount > 0 else { return 0 }
        return min(Double(currentPage + 1) / Double(pageCount), 1)
    }

    var progressPercent: Int {
        Int(progress * 100)
    }
}
