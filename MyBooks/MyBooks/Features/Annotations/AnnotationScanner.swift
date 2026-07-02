//
//  AnnotationScanner.swift
//  MyBooks
//
//  Created by clarafication on 6/26/26.
//

import Foundation
import PDFKit

final class AnnotationScanner {

    func summary(for book: Book) -> AnnotationSummary {
        let didAccess = book.url.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                book.url.stopAccessingSecurityScopedResource()
            }
        }

        guard let document = PDFDocument(url: book.url) else {
            return AnnotationSummary()
        }

        var summary = AnnotationSummary()

        for pageIndex in 0..<document.pageCount {
            guard let page = document.page(at: pageIndex) else { continue }

            for annotation in page.annotations {
                switch annotation.type {
                case "Highlight":
                    summary.highlights += 1

                    if let note = annotation.contents,
                       !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        summary.notes += 1
                    }

                case "Ink":
                    summary.ink += 1
                    summary.handwrittenNotePages.insert(pageIndex + 1)

                default:
                    break
                }
            }
        }

        return summary
    }

    func highlights(for book: Book) -> [HighlightRecord] {
        let didAccess = book.url.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                book.url.stopAccessingSecurityScopedResource()
            }
        }

        guard let document = PDFDocument(url: book.url) else {
            return []
        }

        var records: [HighlightRecord] = []

        for pageIndex in 0..<document.pageCount {
            guard let page = document.page(at: pageIndex) else { continue }

            for annotation in page.annotations where annotation.type == "Highlight" {
                let text = annotation.contents?
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                records.append(
                    HighlightRecord(
                        pageIndex: pageIndex,
                        text: text?.isEmpty == false ? text! : "Highlight on page \(pageIndex + 1)"
                    )
                )
            }
        }

        return records
    }
}

struct AnnotationSummary {
    var highlights = 0
    var notes = 0
    var bookmarks = 0
    var ink = 0
    var handwrittenNotePages: Set<Int> = []
}

struct HighlightRecord: Identifiable, Hashable {
    let id = UUID()
    let pageIndex: Int
    let text: String
}
