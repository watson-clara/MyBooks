//
//  ReaderScreen.swift
//  MyBooks
//
//  Created by clarafication on 6/26/26.
//

import SwiftUI
import SwiftData

struct ReaderScreen: View {

    let book: Book
    let metadata: BookMetadata
    let initialPageIndex: Int
    
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var controller: PDFReaderController
    @State private var mode: ReaderMode = .reading
    @State private var annotationSessionManager = AnnotationSessionManager()
    private let annotationService = AnnotationService()
    @State private var saveManager = PDFSaveManager()
    
    @Query private var allAnnotations: [AnnotationRecord]

    init(
        book: Book,
        metadata: BookMetadata,
        initialPageIndex: Int? = nil
    ) {
        self.book = book
        self.metadata = metadata
        self.initialPageIndex = initialPageIndex ?? metadata.currentPage
        _controller = State(initialValue: PDFReaderController(book: book))
    }

    var body: some View {
        PDFReaderView(
            book: book,
            controller: controller,
            initialPageIndex: initialPageIndex,
            libraryURL: appState.libraryURL,
            mode: $mode,
            annotationSessionManager: annotationSessionManager,
            annotations: allAnnotations.filter { $0.bookID == book.id },
            saveManager: saveManager,
            onPageChanged: { pageIndex in
                metadata.currentPage = pageIndex
                try? modelContext.save()
            }
        )
        .overlay(alignment: Alignment.topTrailing) {

            if saveManager.isSaving {

                Label("Saving…", systemImage: "arrow.triangle.2.circlepath")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding()

            }

        }
        .onAppear {
            controller.onHighlightCreated = { pageIndex, selectedText in
                metadata.highlightsCount += 1
                try? modelContext.save()
            }
        }
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if mode == .reading {
                    Button {
                        annotationSessionManager.beginSession()
                        mode = .annotating
                    } label: {
                        Label("Annotate", systemImage: "pencil.and.outline")
                    }
                } else {
                    Button("Cancel") {
                        annotationSessionManager.discardSession()
                        mode = .reading
                    }
                    Button("Done") {
                        if let result = annotationSessionManager.finishSession(
                            pdfView: controller.pdfView
                        ) {
                            let record = annotationService.createAnnotation(
                                bookID: book.id,
                                sessionResult: result,
                                context: modelContext
                            )

                            annotationSessionManager.renderTemporaryPDFAnnotation(
                                record: record,
                                sessionResult: result,
                                pdfView: controller.pdfView
                            )
                        }

                        mode = .reading
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
