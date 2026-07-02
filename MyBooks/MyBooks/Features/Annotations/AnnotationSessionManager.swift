//
//  AnnotationSessionManager.swift
//  MyBooks
//
//  Created by clarafication on 7/1/26.
//

import Foundation
import PencilKit
import PDFKit

@Observable
final class AnnotationSessionManager {

    var canvasView: PKCanvasView?
    
    private let annotationWriter = PDFAnnotationWriter()

    private var toolPicker: PKToolPicker?

    func beginSession() {
        guard let canvasView else { return }

        canvasView.drawing = PKDrawing()
        canvasView.becomeFirstResponder()

        let picker = PKToolPicker()
        picker.setVisible(true, forFirstResponder: canvasView)
        picker.addObserver(canvasView)

        toolPicker = picker
    }

    func discardSession() {
        canvasView?.drawing = PKDrawing()
        hideToolPicker()
    }

    func finishSession(pdfView: PDFView?) -> AnnotationSessionResult? {
        guard
            let canvasView,
            let pdfView,
            let page = pdfView.currentPage,
            let document = pdfView.document
        else {
            hideToolPicker()
            return nil
        }

        let drawing = canvasView.drawing

        guard !drawing.strokes.isEmpty else {
            hideToolPicker()
            return nil
        }

        let pageIndex = document.index(for: page)

        let result = AnnotationSessionResult(
            drawing: drawing,
            pageIndex: pageIndex,
            canvasBounds: canvasView.bounds
        )

        canvasView.drawing = PKDrawing()
        hideToolPicker()

        return result
    }

    private func hideToolPicker() {
        guard let canvasView else { return }

        toolPicker?.setVisible(false, forFirstResponder: canvasView)
        toolPicker?.removeObserver(canvasView)
        canvasView.resignFirstResponder()
        toolPicker = nil
    }
    
    func renderTemporaryPDFAnnotation(
        record: AnnotationRecord,
        sessionResult: AnnotationSessionResult,
        pdfView: PDFView?
    ) {
        guard
            let pdfView,
            let document = pdfView.document,
            let page = document.page(at: sessionResult.pageIndex)
        else {
            return
        }

        annotationWriter.writeTemporaryInk(
            recordID: record.id,
            drawing: sessionResult.drawing,
            canvasBounds: sessionResult.canvasBounds,
            to: page
        )
    }
}
