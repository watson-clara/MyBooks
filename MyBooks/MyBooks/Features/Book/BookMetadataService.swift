//
//  BookMetadataService.swift
//  MyBooks
//
//  Created by clarafication on 6/29/26.
//

import Foundation
import SwiftData

struct BookMetadataService {

    func createTag(named name: String, colorHex: String, context: ModelContext) -> BookTag {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        let descriptor = FetchDescriptor<BookTag>(
            predicate: #Predicate { tag in tag.name == trimmedName }
        )

        if let existing = try? context.fetch(descriptor).first {
            existing.colorHex = colorHex
            try? context.save()
            return existing
        }

        let tag = BookTag(name: trimmedName, colorHex: colorHex)
        context.insert(tag)
        try? context.save()
        return tag
    }

    func updateTag(_ tag: BookTag, name: String, colorHex: String, context: ModelContext) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        tag.name = trimmedName
        tag.colorHex = colorHex
        try? context.save()
    }

    func deleteTag(_ tag: BookTag, from metadataItems: [BookMetadata], context: ModelContext) {
        for metadata in metadataItems {
            metadata.tags.removeAll { $0.id == tag.id }
        }

        context.delete(tag)
        try? context.save()
    }

    func createCategory(named name: String, context: ModelContext) -> BookCategory {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        let descriptor = FetchDescriptor<BookCategory>(
            predicate: #Predicate { category in category.name == trimmedName }
        )

        if let existing = try? context.fetch(descriptor).first {
            return existing
        }

        let category = BookCategory(name: trimmedName)
        context.insert(category)
        try? context.save()
        return category
    }

    func updateCategory(_ category: BookCategory, name: String, context: ModelContext) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        category.name = trimmedName
        try? context.save()
    }

    func deleteCategory(_ category: BookCategory, from metadataItems: [BookMetadata], context: ModelContext) {
        for metadata in metadataItems where metadata.category?.id == category.id {
            metadata.category = nil
        }

        context.delete(category)
        try? context.save()
    }
}
