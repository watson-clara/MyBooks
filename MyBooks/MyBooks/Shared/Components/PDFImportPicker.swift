//
//  PDFImportPicker.swift
//  MyBooks
//
//  Created by clarafication on 6/29/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct PDFImportPicker: UIViewControllerRepresentable {

    let onSelect: ([URL]) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.pdf],
            asCopy: true
        )

        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator

        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIDocumentPickerViewController,
        context: Context
    ) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {

        let onSelect: ([URL]) -> Void

        init(onSelect: @escaping ([URL]) -> Void) {
            self.onSelect = onSelect
        }

        func documentPicker(
            _ controller: UIDocumentPickerViewController,
            didPickDocumentsAt urls: [URL]
        ) {
            onSelect(urls)
        }
    }
}
