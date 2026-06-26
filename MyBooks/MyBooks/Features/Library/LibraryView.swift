//
//  LibraryView.swift
//  MyBooks
//
//  Created by clarafication on 6/26/26.
//

import SwiftUI

struct LibraryView: View {

    @Environment(AppState.self) private var appState
    @State private var isShowingFolderPicker = false

    var body: some View {
        VStack(spacing: 24) {

            if let libraryURL = appState.libraryURL {
                librarySelectedView(libraryURL)
            } else {
                noLibraryView
            }

        }
        .padding()
        .navigationTitle("Library")
        .sheet(isPresented: $isShowingFolderPicker) {
            FolderPicker { url in
                appState.setLibraryFolder(url)
                isShowingFolderPicker = false
            }
        }
    }

    private var noLibraryView: some View {
        ContentUnavailableView {
            Label("No Library Selected", systemImage: "books.vertical")
        } description: {
            Text("Choose the folder that contains your PDF books.")
        } actions: {
            Button {
                isShowingFolderPicker = true
            } label: {
                Label("Choose Library Folder", systemImage: "folder")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func librarySelectedView(_ url: URL) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.fill")
                .font(.system(size: 56))

            Text("Library Folder Selected")
                .font(.title2)
                .fontWeight(.semibold)

            Text(url.lastPathComponent)
                .foregroundStyle(.secondary)

            Button("Choose Different Folder") {
                isShowingFolderPicker = true
            }

            Button("Clear Library Folder", role: .destructive) {
                appState.clearLibraryFolder()
            }
        }
    }
}

#Preview {
    LibraryView()
        .environment(AppState())
}
