//
//  PDFAnnotationWriter.swift
//  MyBooks
//
//  Created by clarafication on 6/30/26.
//

import Foundation
import PDFKit
import PencilKit
import UIKit

final class MyBooksDrawingPDFAnnotation: PDFAnnotation {

    private let image: UIImage

    init(
        recordID: UUID,
        image: UIImage,
        bounds: CGRect
    ) {
        self.image = image

        super.init(
            bounds: bounds,
            forType: .stamp,
            withProperties: nil
        )

        self.contents = "MyBooksAnnotation:\(recordID.uuidString)"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(
        with box: PDFDisplayBox,
        in context: CGContext
    ) {
        guard let cgImage = image.cgImage else {
            return
        }

        context.saveGState()

        context.draw(
            cgImage,
            in: bounds
        )

        context.restoreGState()
    }
}

struct PDFAnnotationWriter {

    private let annotationPrefix = "MyBooksAnnotation:"

    func writeTemporaryInk(
        recordID: UUID,
        drawing: PKDrawing,
        canvasBounds: CGRect,
        to page: PDFPage
    ) {
        removeTemporaryInk(
            recordID: recordID,
            from: page
        )

        guard !drawing.strokes.isEmpty else {
            return
        }

        let pageBounds = page.bounds(for: .cropBox)

        let image = drawing.image(
            from: canvasBounds,
            scale: UIScreen.main.scale
        )

        let annotation = MyBooksDrawingPDFAnnotation(
            recordID: recordID,
            image: image,
            bounds: pageBounds
        )

        page.addAnnotation(annotation)
    }

    func removeTemporaryInk(
        recordID: UUID,
        from page: PDFPage
    ) {
        let marker = "\(annotationPrefix)\(recordID.uuidString)"

        let annotationsToRemove = page.annotations.filter {
            $0.contents == marker
        }

        for annotation in annotationsToRemove {
            page.removeAnnotation(annotation)
        }
    }

    func removeAllMyBooksTemporaryInk(from page: PDFPage) {
        let annotationsToRemove = page.annotations.filter {
            $0.contents?.hasPrefix(annotationPrefix) == true
        }

        for annotation in annotationsToRemove {
            page.removeAnnotation(annotation)
        }
    }
}
