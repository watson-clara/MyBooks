//
//  PDFReaderView.swift
//  MyBooks
//
//  Created by clarafication on 6/26/26.
//

import SwiftUI
import PDFKit
import PencilKit

final class MyBooksPDFView: PDFView {
}

final class PDFReaderContainerView: UIView {

    let pdfView: MyBooksPDFView
    let blockerView: UIView
    let canvasView: PKCanvasView

    var isAnnotating = false

    init(pdfView: MyBooksPDFView, canvasView: PKCanvasView) {
        self.pdfView = pdfView
        self.canvasView = canvasView
        self.blockerView = UIView(frame: .zero)

        super.init(frame: .zero)

        addSubview(pdfView)

        blockerView.backgroundColor = .clear
        blockerView.isHidden = true
        blockerView.isUserInteractionEnabled = false
        addSubview(blockerView)

        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.clipsToBounds = true
        canvasView.isHidden = true
        canvasView.isUserInteractionEnabled = false
        addSubview(canvasView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        pdfView.frame = bounds
        blockerView.frame = bounds
        alignCanvasToCurrentPage()
    }

    func setAnnotating(_ isEnabled: Bool) {
        isAnnotating = isEnabled

        blockerView.isHidden = !isEnabled
        blockerView.isUserInteractionEnabled = isEnabled

        canvasView.isHidden = !isEnabled
        canvasView.isUserInteractionEnabled = isEnabled

        for recognizer in pdfView.gestureRecognizers ?? [] {
            recognizer.isEnabled = !isEnabled
        }

        alignCanvasToCurrentPage()
    }

    func alignCanvasToCurrentPage() {
        guard
            isAnnotating,
            let page = pdfView.currentPage
        else {
            return
        }

        let pageBounds = page.bounds(for: .cropBox)
        let pageFrame = pdfView.convert(pageBounds, from: page)

        canvasView.frame = pageFrame
    }
}

struct PDFReaderView: UIViewRepresentable {

    let book: Book
    let controller: PDFReaderController
    let initialPageIndex: Int
    let libraryURL: URL?
    @Binding var mode: ReaderMode
    let annotationSessionManager: AnnotationSessionManager
    let annotations: [AnnotationRecord]
    let saveManager: PDFSaveManager
    let onPageChanged: (Int) -> Void

    private let annotationWriter = PDFAnnotationWriter()

    func makeCoordinator() -> Coordinator {
        Coordinator(onPageChanged: onPageChanged)
    }

    func makeUIView(context: Context) -> PDFReaderContainerView {
        let pdfView = MyBooksPDFView()
        let canvasView = PKCanvasView()

        annotationSessionManager.canvasView = canvasView

        let containerView = PDFReaderContainerView(
            pdfView: pdfView,
            canvasView: canvasView
        )

        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal
        pdfView.usePageViewController(true)
        pdfView.backgroundColor = .systemBackground
        pdfView.displaysPageBreaks = true
        pdfView.pageBreakMargins = UIEdgeInsets(
            top: 20,
            left: 20,
            bottom: 20,
            right: 20
        )

        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(
            .pen,
            color: .systemBlue,
            width: 3
        )

        if let document = loadPDFDocument() {
            pdfView.document = document

            let signature = annotationSignature(for: annotations)

            renderTemporaryPDFAnnotations(
                annotations,
                in: document
            )

            context.coordinator.renderedAnnotationSignature = signature

            if let page = document.page(at: initialPageIndex) {
                pdfView.go(to: page)
            }
        } else {
            print("Failed to load PDF at:", book.url)
        }

        controller.pdfView = pdfView

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.pageChanged(_:)),
            name: Notification.Name.PDFViewPageChanged,
            object: pdfView
        )

        containerView.setAnnotating(mode == .annotating)

        return containerView
    }

    func updateUIView(_ containerView: PDFReaderContainerView, context: Context) {
        containerView.setAnnotating(mode == .annotating)

        guard let document = containerView.pdfView.document else {
            return
        }

        let signature = annotationSignature(for: annotations)

        guard signature != context.coordinator.renderedAnnotationSignature else {
            return
        }

        renderTemporaryPDFAnnotations(
            annotations,
            in: document
        )

        context.coordinator.renderedAnnotationSignature = signature
    }

    private func annotationSignature(
        for annotations: [AnnotationRecord]
    ) -> String {
        annotations
            .sorted { $0.id.uuidString < $1.id.uuidString }
            .map { annotation in
                [
                    annotation.id.uuidString,
                    "\(annotation.pageIndex)",
                    "\(annotation.modifiedAt.timeIntervalSince1970)",
                    "\(annotation.drawingData?.count ?? 0)"
                ].joined(separator: ":")
            }
            .joined(separator: "|")
    }

    private func renderTemporaryPDFAnnotations(
        _ annotations: [AnnotationRecord],
        in document: PDFDocument
    ) {
        for pageIndex in 0..<document.pageCount {
            guard let page = document.page(at: pageIndex) else {
                continue
            }

            annotationWriter.removeAllMyBooksTemporaryInk(from: page)
        }

        for annotation in annotations {
            guard
                let drawingData = annotation.drawingData,
                let drawing = try? PKDrawing(data: drawingData),
                let page = document.page(at: annotation.pageIndex)
            else {
                continue
            }

            let canvasBounds: CGRect

            if let locationData = annotation.locationData,
               let decoded = try? JSONDecoder().decode(
                CodableRect.self,
                from: locationData
               ) {
                canvasBounds = decoded.rect
            } else {
                let pageBounds = page.bounds(for: .cropBox)
                canvasBounds = CGRect(
                    origin: .zero,
                    size: pageBounds.size
                )
            }

            annotationWriter.writeTemporaryInk(
                recordID: annotation.id,
                drawing: drawing,
                canvasBounds: canvasBounds,
                to: page
            )
        }
    }

    private func loadPDFDocument() -> PDFDocument? {
        let didAccessLibrary = libraryURL?.startAccessingSecurityScopedResource() ?? false
        let didAccessBook = book.url.startAccessingSecurityScopedResource()

        defer {
            if didAccessBook {
                book.url.stopAccessingSecurityScopedResource()
            }

            if didAccessLibrary {
                libraryURL?.stopAccessingSecurityScopedResource()
            }
        }

        if let document = PDFDocument(url: book.url) {
            return document
        }

        if let data = coordinatedPDFData(from: book.url),
           let document = PDFDocument(data: data) {
            return document
        }

        return nil
    }

    private func coordinatedPDFData(from url: URL) -> Data? {
        var result: Data?
        var coordinationError: NSError?

        let coordinator = NSFileCoordinator(filePresenter: nil)

        coordinator.coordinate(
            readingItemAt: url,
            options: [],
            error: &coordinationError
        ) { coordinatedURL in
            result = try? Data(contentsOf: coordinatedURL)
        }

        if let coordinationError {
            print("File coordination failed:", coordinationError)
        }

        return result
    }

    final class Coordinator: NSObject {

        var renderedAnnotationSignature = ""

        let onPageChanged: (Int) -> Void

        init(onPageChanged: @escaping (Int) -> Void) {
            self.onPageChanged = onPageChanged
        }

        @objc func pageChanged(_ notification: Notification) {
            guard
                let pdfView = notification.object as? PDFView,
                let document = pdfView.document,
                let currentPage = pdfView.currentPage
            else {
                return
            }

            let pageIndex = document.index(for: currentPage)

            if pageIndex != NSNotFound {
                onPageChanged(pageIndex)
            }
        }
    }
}
