//
//  BookCategoryManagerSheet.swift
//  MyBooks
//
//  Created by clarafication on 6/29/26.
//

import SwiftUI
import SwiftData

struct BookCategoryManagerSheet: View {

    @Bindable var metadata: BookMetadata

    @Query private var allCategories: [BookCategory]
    @Query private var allMetadata: [BookMetadata]

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var isCreatingCategory = false
    @State private var newCategoryName = ""

    @State private var editingCategory: BookCategory?
    @State private var editingCategoryName = ""

    private let libraryDataService = BookMetadataService()

    var body: some View {
        NavigationStack {
            List {
                categoryListSection
                newCategorySection
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var categoryListSection: some View {
        Section {
            Button {
                metadata.category = nil
            } label: {
                HStack {
                    Image(systemName: metadata.category == nil ? "checkmark.circle.fill" : "circle")
                    Text("None")
                }
            }

            ForEach(allCategories) { category in
                if editingCategory?.id == category.id {
                    editCategoryRow(category)
                } else {
                    categorySelectionRow(category)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                libraryDataService.deleteCategory(
                                    category,
                                    from: allMetadata,
                                    context: modelContext
                                )
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                editingCategory = category
                                editingCategoryName = category.name
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                }
            }
        }
    }

    private var newCategorySection: some View {
        Section {
            if isCreatingCategory {
                TextField("Category name", text: $newCategoryName)

                Button {
                    createCategory()
                } label: {
                    Label("Create Category", systemImage: "checkmark")
                }
            } else {
                Button {
                    newCategoryName = ""
                    isCreatingCategory = true
                } label: {
                    Label("New Category", systemImage: "plus")
                }
            }
        }
    }

    private func categorySelectionRow(_ category: BookCategory) -> some View {
        Button {
            metadata.category = category
        } label: {
            HStack {
                Image(systemName: metadata.category?.id == category.id ? "checkmark.circle.fill" : "circle")
                Text(category.name)
            }
        }
    }

    private func editCategoryRow(_ category: BookCategory) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Category name", text: $editingCategoryName)

            HStack {
                Button("Cancel") {
                    editingCategory = nil
                }

                Spacer()

                Button("Save") {
                    libraryDataService.updateCategory(
                        category,
                        name: editingCategoryName,
                        context: modelContext
                    )

                    editingCategory = nil
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.vertical, 6)
    }

    private func createCategory() {
        let name = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        let category = libraryDataService.createCategory(
            named: name,
            context: modelContext
        )

        metadata.category = category
        newCategoryName = ""
        isCreatingCategory = false
    }
}
