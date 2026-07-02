//
//  PDFReaderController.swift
//  MyBooks
//
//  Created by clarafication on 6/26/26.
//

import Foundation
import PDFKit
import PencilKit

@Observable
final class PDFReaderController {

    let book: Book

    var onHighlightCreated: ((Int, String) -> Void)?

    weak var pdfView: PDFView?

    init(book: Book) {
        self.book = book
    }
    
    func enterDrawingMode() {
        guard let pdfView else { return }

        for recognizer in pdfView.gestureRecognizers ?? [] {
            recognizer.isEnabled = false
        }
    }

    func exitDrawingMode() {
        guard let pdfView else { return }

        for recognizer in pdfView.gestureRecognizers ?? [] {
            recognizer.isEnabled = true
        }
    }

    func highlightSelection() {
        guard
            let pdfView,
            let selection = pdfView.currentSelection
        else {
            return
        }

        let selectedText = selection.string ?? ""

        for lineSelection in selection.selectionsByLine() {
            guard
                let page = lineSelection.pages.first,
                let document = pdfView.document
            else {
                continue
            }

            let pageIndex = document.index(for: page)
            let bounds = lineSelection.bounds(for: page)

            let annotation = PDFAnnotation(
                bounds: bounds,
                forType: .highlight,
                withProperties: nil
            )

            annotation.color = UIColor.systemYellow.withAlphaComponent(0.35)
            page.addAnnotation(annotation)

            onHighlightCreated?(pageIndex, selectedText)
        }
        pdfView.clearSelection()
    }

    func addTextAnnotation(_ text: String) {
        guard let pdfView, let page = pdfView.currentPage else { return }

        let pageBounds = page.bounds(for: .cropBox)

        let annotationBounds = CGRect(
            x: pageBounds.midX - 120,
            y: pageBounds.midY - 40,
            width: 240,
            height: 80
        )

        let annotation = PDFAnnotation(
            bounds: annotationBounds,
            forType: .freeText,
            withProperties: nil
        )

        annotation.contents = text
        annotation.font = UIFont.systemFont(ofSize: 16)
        annotation.fontColor = .black
        annotation.color = UIColor.systemYellow.withAlphaComponent(0.75)

        page.addAnnotation(annotation)
        savePDF()
    }

    func savePDF() {
        guard let document = pdfView?.document else { return }

        let didAccess = book.url.startAccessingSecurityScopedResource()
        document.write(to: book.url)

        if didAccess {
            book.url.stopAccessingSecurityScopedResource()
        }
    }
    func saveCurrentInkToPDF() {
        print("Save ink tapped")
    }
}
