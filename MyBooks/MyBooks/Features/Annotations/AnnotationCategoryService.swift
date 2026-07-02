//
//  AnnotationCategoryService.swift
//  MyBooks
//
//  Created by clarafication on 7/1/26.
//

import Foundation
import SwiftData

struct AnnotationCategoryService {

    func createDefaultCategories(
        context: ModelContext
    ) {

        let defaults = [
            ("Quote", "#FFCC00"),
            ("Vocabulary", "#34C759")
        ]

        for (name, color) in defaults {

            let descriptor = FetchDescriptor<AnnotationCategory>(
                predicate: #Predicate { category in
                    category.name == name
                }
            )

            if (try? context.fetch(descriptor).first) == nil {

                context.insert(
                    AnnotationCategory(
                        name: name,
                        colorHex: color
                    )
                )
            }
        }

        try? context.save()
    }
    
    func createCategory(
        named name: String,
        colorHex: String = "#FFCC00",
        context: ModelContext
    ) -> AnnotationCategory {

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        let descriptor = FetchDescriptor<AnnotationCategory>(
            predicate: #Predicate { category in
                category.name == trimmedName
            }
        )

        if let existing = try? context.fetch(descriptor).first {
            return existing
        }

        let category = AnnotationCategory(
            name: trimmedName,
            colorHex: colorHex
        )

        context.insert(category)
        try? context.save()

        return category
    }
}
