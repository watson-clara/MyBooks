//
//  LibraryView.swift
//  MyBooks
//
//  Created by clarafication on 6/26/26.
//

import SwiftUI
import SwiftData
import UIKit
import UniformTypeIdentifiers

struct LibraryView: View {

    @Environment(\.modelContext) private var modelContext
    @Query private var metadataItems: [BookMetadata]
    @Query private var annotationRecords: [AnnotationRecord]

    @State private var viewModel = LibraryViewModel()
    @State private var isShowingImportPicker = false
    @State private var coverImages: [String: UIImage] = [:]

    private let appLibraryService = AppLibraryService()
    private let thumbnailService = PDFThumbnailService()
    private let annotationScanner = AnnotationScanner()

    private let columns = [
        GridItem(.adaptive(minimum: 170), spacing: 28)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.books.isEmpty {
                    emptyLibraryView
                } else {
                    bookGrid
                }
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingImportPicker = true
                    } label: {
                        Label("Import PDFs", systemImage: "plus")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        scanLibrary()
                    } label: {
                        Label("Scan", systemImage: "arrow.clockwise")
                    }
                }
            }
            .fileImporter(
                isPresented: $isShowingImportPicker,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    importPDFs(urls)

                case .failure(let error):
                    print("PDF import failed:", error)
                }
            }
            .onAppear {
                scanLibrary()
            }
        }
    }

    private var emptyLibraryView: some View {
        ContentUnavailableView {
            Label("No PDFs Imported", systemImage: "books.vertical")
        } description: {
            Text("Import PDFs into MyBooks to start building your library.")
        } actions: {
            Button {
                isShowingImportPicker = true
            } label: {
                Label("Import PDFs", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var bookGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 32) {
                ForEach(viewModel.books) { book in
                    if let metadata = metadata(for: book) {
                        NavigationLink {
                            BookInfoView(
                                book: book,
                                metadata: metadata,
                                coverImage: coverImages[book.id]
                            )
                        } label: {
                            BookCardView(
                                book: book,
                                metadata: metadata,
                                coverImage: coverImages[book.id]
                            )
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteBook(book)
                            } label: {
                                Label("Delete from Library", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .refreshable {
            scanLibrary()
        }
    }

    private func importPDFs(_ urls: [URL]) {
        do {
            try appLibraryService.importPDFs(from: urls)
            scanLibrary()
        } catch {
            print("Failed to import PDFs:", error)
        }
    }

    private func scanLibrary() {
        do {
            let libraryURL = try appLibraryService.libraryFolderURL()
            viewModel.scan(folder: libraryURL)
            createMissingMetadata()
            loadMissingCovers()
        } catch {
            print("Failed to scan app library:", error)
        }
    }

    private func metadata(for book: Book) -> BookMetadata? {
        metadataItems.first { $0.fileID == book.id }
    }

    private func createMissingMetadata() {
        for book in viewModel.books {
            let pageCount = thumbnailService.pageCount(for: book)
            let summary = annotationScanner.summary(for: book)

            if let existingMetadata = metadataItems.first(where: { $0.fileID == book.id }) {
                existingMetadata.pageCount = pageCount
                existingMetadata.highlightsCount = summary.highlights
                existingMetadata.notesCount = summary.notes
                existingMetadata.bookmarksCount = summary.bookmarks
                existingMetadata.inkCount = summary.ink
            } else {
                let metadata = BookMetadata(
                    fileID: book.id,
                    defaultTitle: book.title,
                    pageCount: pageCount
                )

                metadata.highlightsCount = summary.highlights
                metadata.notesCount = summary.notes
                metadata.bookmarksCount = summary.bookmarks
                metadata.inkCount = summary.ink

                modelContext.insert(metadata)
            }
        }

        try? modelContext.save()
    }

    private func loadMissingCovers() {
        for book in viewModel.books {
            if coverImages[book.id] == nil {
                coverImages[book.id] = thumbnailService.coverImage(for: book)
            }
        }
    }
    private func deleteBook(_ book: Book) {
        do {
            try appLibraryService.deletePDF(at: book.url)

            if let metadata = metadata(for: book) {
                modelContext.delete(metadata)
            }

            for record in annotationRecords where record.bookID == book.id {
                modelContext.delete(record)
            }

            coverImages.removeValue(forKey: book.id)

            try? modelContext.save()

            scanLibrary()
        } catch {
            print("Failed to delete book:", error)
        }
    }
}
