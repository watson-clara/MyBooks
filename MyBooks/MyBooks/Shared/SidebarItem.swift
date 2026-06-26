//
//  SidebarItem.swift
//  MyBooks
//
//  Created by clarafication on 6/26/26.
//


import Foundation

enum SidebarItem: String, CaseIterable, Identifiable, Hashable {

    case library
    case favorites
    case recent
    case collections
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .library:
            return "Library"

        case .favorites:
            return "Favorites"

        case .recent:
            return "Recent"

        case .collections:
            return "Collections"

        case .settings:
            return "Settings"
        }
    }

    var systemImage: String {

        switch self {

        case .library:
            return "books.vertical.fill"

        case .favorites:
            return "star.fill"

        case .recent:
            return "clock.fill"

        case .collections:
            return "folder.fill"

        case .settings:
            return "gearshape.fill"

        }

    }

}
