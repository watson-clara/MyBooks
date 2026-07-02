//
//  PDFThumbnailService.swift
//  MyBooks
//
//  Created by clarafication on 6/26/26.
//

import Foundation
import PDFKit
import UIKit

final class PDFThumbnailService {

    func coverImage(for book: Book, size: CGSize = CGSize(width: 300, height: 420)) -> UIImage? {
        let didAccess = book.url.startAccessingSecurityScopedResource()

        defer {
            if didAccess {
                book.url.stopAccessingSecurityScopedResource()
            }
        }

        guard
            let document = PDFDocument(url: book.url),
            let page = document.page(at: 0)
        else {
            return nil
        }

        return page.thumbnail(of: size, for: .cropBox)
    }

    func pageCount(for book: Book) -> Int {
        let didAccess = book.url.startAccessingSecurityScopedResource()

        defer {
            if didAccess {
                book.url.stopAccessingSecurityScopedResource()
            }
        }

        return PDFDocument(url: book.url)?.pageCount ?? 0
    }
}
