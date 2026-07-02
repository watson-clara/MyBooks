//
//  BookInfoView.swift
//  MyBooks
//
//  Created by clarafication on 6/26/26.
//


import SwiftUI
import SwiftData
import UIKit

struct BookInfoView: View {

    let book: Book
    @Bindable var metadata: BookMetadata
    let coverImage: UIImage?

    @Query private var allTags: [BookTag]
    @Query private var allCategories: [BookCategory]
    
    @Environment(\.modelContext) private var modelContext

    @State private var annotationSummary = AnnotationSummary()
    @State private var isManagingTags = false
    @State private var isAddingCategory = false
    @State private var newCategoryName = ""
    @State private var isShowingBookInfoSheet = false
    @State private var isShowingCategorySheet = false
    @State private var isCreatingCategory = false
    

    private let annotationScanner = AnnotationScanner()
    private let libraryDataService = BookMetadataService()

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                coverSection
                bookSummarySection
                continueReadingButton
                readingProgressSection
                bookNotesSection
                annotationsSection
                bookInformationSection
                organizationSection
                pdfInformationSection
            }
            .padding()
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(metadata.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isManagingTags) {
            TagManagerSheet(metadata: metadata)
        }
        .sheet(isPresented: $isShowingCategorySheet) {
            BookCategoryManagerSheet(metadata: metadata)
        }
        .sheet(isPresented: $isShowingBookInfoSheet) {
            bookInfoSheet
        }
        .onAppear {
            annotationSummary = annotationScanner.summary(for: book)
        }
    }

    private var coverSection: some View {
        VStack(spacing: 12) {
            if let coverImage {
                Image(uiImage: coverImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(radius: 8)
            } else {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.quaternary)
                    .frame(width: 240, height: 330)
                    .overlay {
                        Image(systemName: "doc.richtext")
                            .font(.system(size: 56))
                            .foregroundStyle(.secondary)
                    }
            }
        }
    }

    private var bookSummarySection: some View {
        VStack(spacing: 10) {
            Text(metadata.displayTitle)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(metadata.displayAuthor)
                .font(.title3)
                .foregroundStyle(.secondary)
            
            

            if let category = metadata.category {
                TagChipView(
                    title: category.name,
                    showsRemoveButton: false
                )
            } else {
                Text("No category")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
                tagChipsRow
            

            if metadata.favorite {
                Label("Favorite", systemImage: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.subheadline)
            }
        }
    }
    

   
    private var bookInfoSheet: some View {
        NavigationStack {
            Form {
                Section("Book Information") {

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Title")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("", text: $metadata.customTitle)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Author")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("", text: $metadata.author)
                            .textFieldStyle(.roundedBorder)
                    }
                }
            }
            .navigationTitle("Edit Book Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isShowingBookInfoSheet = false
                    }
                }
            }
        }
    }

    private var tagChipsRow: some View {
        FlowLayout(spacing: 8) {
            ForEach(metadata.tags) { tag in
                TagChipView(
                    title: tag.name,
                    colorHex: tag.colorHex,
                    showsRemoveButton: true
                ) {
                    metadata.tags.removeAll { $0.id == tag.id }
                }
            }

            Button {
                isManagingTags = true
            } label: {
                Label("Add Tag", systemImage: "plus")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.quaternary)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private var continueReadingButton: some View {
        NavigationLink {
            ReaderScreen(book: book, metadata: metadata)
        } label: {
            Label("Continue Reading", systemImage: "book.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    private var readingProgressSection: some View {
        card {

            Text("Page \(metadata.currentPage + 1) of \(max(metadata.pageCount, 1))")

            ProgressView(value: metadata.progress)

            Text("\(metadata.progressPercent)% read")
                .foregroundStyle(.secondary)
        }
    }

    private var annotationsSection: some View {
        card {
            sectionTitle("Annotations")

            annotationRow("Highlights", annotationSummary.highlights)
            annotationRow("Notes", annotationSummary.notes)
            annotationRow("Bookmarks", annotationSummary.bookmarks)
            annotationRow("Ink", annotationSummary.ink)
        }
    }

    private var bookNotesSection: some View {
        card {
            sectionTitle("Book Notes")

            TextEditor(text: $metadata.bookNotes)
                .frame(minHeight: 140)
                .padding(8)
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var bookInformationSection: some View {
        card {
            HStack {
                sectionTitle("Book Information")

                Spacer()

                Button("Edit") {
                    isShowingBookInfoSheet = true
                }
            }

            infoRow("Title", metadata.displayTitle)
            infoRow("Author", metadata.displayAuthor)

            
        }
    }
    
    private var organizationSection: some View {
        card {
            sectionTitle("Organization")

            HStack {
                Text("Category")
                    .foregroundStyle(.secondary)

                Spacer()

                Text(metadata.category?.name ?? "None")

                Button("Change") {
                    isShowingCategorySheet = true
                }
            }

            HStack {
                Text("Favorite")
                    .foregroundStyle(.secondary)

                Spacer()

                Toggle("", isOn: $metadata.favorite)
                    .labelsHidden()
            }
        }
    }

    private var pdfInformationSection: some View {
        card {
            sectionTitle("PDF Information")

            infoRow("Filename", book.url.lastPathComponent)
            infoRow("Pages", "\(metadata.pageCount)")
            infoRow("Location Saved", book.url.deletingLastPathComponent().lastPathComponent)
        }
    }
    
    
    
    private func toggleTag(_ tag: BookTag) {
        if metadata.tags.contains(where: { $0.id == tag.id }) {
            metadata.tags.removeAll { $0.id == tag.id }
        } else {
            metadata.tags.append(tag)
        }
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
    }

    private func annotationRow(_ title: String, _ count: Int) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(count)")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
        .padding(.vertical, 4)
    }
}



