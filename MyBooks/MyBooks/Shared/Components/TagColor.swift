//
//  TagColor.swift
//  MyBooks
//
//  Created by clarafication on 6/29/26.
//

import SwiftUI

enum TagColor: String, CaseIterable, Identifiable {
    case blue
    case purple
    case orange
    case green
    case teal
    case pink
    case yellow
    case red
    case indigo
    case gray

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .blue: .blue
        case .purple: .purple
        case .orange: .orange
        case .green: .green
        case .teal: .teal
        case .pink: .pink
        case .yellow: .yellow
        case .red: .red
        case .indigo: .indigo
        case .gray: .gray
        }
    }
}
