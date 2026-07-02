//
//  MyBooksApp.swift
//  MyBooks
//
//  Created by clarafication on 6/26/26.
//
import SwiftUI
import SwiftData

@main
struct MyBooksApp: App {

    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                List(
                    SidebarItem.allCases,
                    selection: $appState.selectedSidebarItem
                ) { item in
                    Label(item.title, systemImage: item.systemImage)
                        .tag(item)
                }
                .navigationTitle("MyBooks")
            } detail: {
                switch appState.selectedSidebarItem ?? .library {
                case .library:
                    LibraryView()

                case .favorites:
                    Text("Favorites")

                case .recent:
                    Text("Recent")

                case .collections:
                    Text("Collections")

                case .settings:
                    NavigationStack {
                        SettingsView()
                    }
                }
            }
            .environment(appState)
        }
        .modelContainer(for: [
            BookMetadata.self,
            AnnotationRecord.self,
            AnnotationCategory.self,
            BookTag.self,
            BookCategory.self
        ])
    }
}
