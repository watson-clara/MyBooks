//
//  TagChipView.swift
//  MyBooks
//
//  Created by clarafication on 6/29/26.
//

import SwiftUI

struct TagChipView: View {

    let title: String
    var colorHex: String = "#8E8E93"

    var showsRemoveButton = false
    var onRemove: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 6) {
            Text(title)

            if showsRemoveButton {
                Button {
                    onRemove?()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .font(.caption)
        .fontWeight(.medium)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(hex: colorHex).opacity(0.16))
        .foregroundStyle(Color(hex: colorHex))
        .clipShape(Capsule())
    }
}
