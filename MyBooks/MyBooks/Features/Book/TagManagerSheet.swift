//
//  TagManagerSheet.swift
//  MyBooks
//
//  Created by clarafication on 6/29/26.
//

import SwiftUI
import SwiftData

struct TagManagerSheet: View {

    @Bindable var metadata: BookMetadata

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var allTags: [BookTag]
    @Query private var allMetadata: [BookMetadata]

    @State private var isCreatingTag = false
    @State private var newTagName = ""
    @State private var newTagColor = Color.blue

    @State private var editingTag: BookTag?
    @State private var editingTagName = ""
    @State private var editingTagColor = Color.blue

    private let libraryDataService = BookMetadataService()

    var body: some View {
        NavigationStack {
            List {
                currentTagsSection
                newTagSection
            }
            .navigationTitle("Manage Tags")
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

    private var currentTagsSection: some View {
        Section("Current Tags") {
            ForEach(allTags) { tag in
                if editingTag?.id == tag.id {
                    editTagRow(tag)
                } else {
                    tagSelectionRow(tag)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                libraryDataService.deleteTag(
                                    tag,
                                    from: allMetadata,
                                    context: modelContext
                                )
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                editingTag = tag
                                editingTagName = tag.name
                                editingTagColor = Color(hex: tag.colorHex)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                }
            }
        }
    }

    private var newTagSection: some View {
        Section("New Tag") {
            if isCreatingTag {
                TextField("Tag Name", text: $newTagName)
                ColorPicker("Color", selection: $newTagColor)

                Button {
                    createNewTag()
                } label: {
                    Label("Create Tag", systemImage: "checkmark")
                }
            } else {
                Button {
                    newTagName = ""
                    newTagColor = .blue
                    isCreatingTag = true
                } label: {
                    Label("New Tag", systemImage: "plus")
                }
            }
        }
    }

    private func tagSelectionRow(_ tag: BookTag) -> some View {
        Button {
            toggleTag(tag)
        } label: {
            HStack {
                Image(systemName: metadata.tags.contains(where: { $0.id == tag.id }) ? "checkmark.circle.fill" : "circle")

                Circle()
                    .fill(Color(hex: tag.colorHex))
                    .frame(width: 16, height: 16)

                Text(tag.name)
                Spacer()
            }
        }
    }

    private func editTagRow(_ tag: BookTag) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Tag Name", text: $editingTagName)
            ColorPicker("Color", selection: $editingTagColor)

            HStack {
                Button("Cancel") {
                    editingTag = nil
                }

                Spacer()

                Button("Save") {
                    libraryDataService.updateTag(
                        tag,
                        name: editingTagName,
                        colorHex: editingTagColor.toHex(),
                        context: modelContext
                    )

                    editingTag = nil
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.vertical, 6)
    }

    private func createNewTag() {
        let name = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        let tag = libraryDataService.createTag(
            named: name,
            colorHex: newTagColor.toHex(),
            context: modelContext
        )

        if !metadata.tags.contains(where: { $0.id == tag.id }) {
            metadata.tags.append(tag)
        }

        newTagName = ""
        newTagColor = .blue
        isCreatingTag = false
    }

    private func toggleTag(_ tag: BookTag) {
        if metadata.tags.contains(where: { $0.id == tag.id }) {
            metadata.tags.removeAll { $0.id == tag.id }
        } else {
            metadata.tags.append(tag)
        }
    }
}
