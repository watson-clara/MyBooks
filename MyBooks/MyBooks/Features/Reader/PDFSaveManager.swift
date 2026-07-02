//
//  PDFSaveManager.swift
//  MyBooks
//
//  Created by clarafication on 6/30/26.
//

import Foundation
import PDFKit

@Observable
final class PDFSaveManager {

    var isSaving = false
    var hasUnsavedChanges = false

    private var saveTask: Task<Void, Never>?

    func markUnsavedAndScheduleSave(
        document: PDFDocument?,
        bookURL: URL
    ) {
        hasUnsavedChanges = true
        saveTask?.cancel()

        saveTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2))

            guard let self, !Task.isCancelled else { return }

            await self.saveInBackground(
                document: document,
                bookURL: bookURL
            )
        }
    }

    @MainActor
    private func setSaving(_ saving: Bool) {
        isSaving = saving
    }

    @MainActor
    private func setSaved() {
        hasUnsavedChanges = false
        isSaving = false
    }

    private func saveInBackground(
        document: PDFDocument?,
        bookURL: URL
    ) async {
        guard let document else { return }

        await setSaving(true)

        await Task.detached(priority: .utility) {
            let didAccess = bookURL.startAccessingSecurityScopedResource()

            if !document.write(to: bookURL) {
                print("Failed to save PDF:", bookURL)
            }

            if didAccess {
                bookURL.stopAccessingSecurityScopedResource()
            }
        }.value

        await setSaved()
    }
}
