//
//  BookCardView.swift
//  MyBooks
//
//  Created by clarafication on 6/26/26.
//

import SwiftUI
import UIKit

struct BookCardView: View {

    let book: Book
    let metadata: BookMetadata
    let coverImage: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            cover

            Text(metadata.displayTitle)
                .font(.headline)
                .lineLimit(2)

            if !metadata.displayAuthor.isEmpty {
                Text(metadata.displayAuthor)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            ProgressView(value: metadata.progress)

            Text("\(metadata.progressPercent)%")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var cover: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 14)
                .fill(.quaternary)

            if let coverImage {
                Image(uiImage: coverImage)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                Image(systemName: "doc.richtext")
                    .font(.system(size: 44))
                    .foregroundStyle(.secondary)
            }

            HStack {
                ProgressView(value: metadata.progress)
                Text("\(metadata.progressPercent)%")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .padding(8)
            .background(.ultraThinMaterial)
        }
        .aspectRatio(0.72, contentMode: .fit)
        .shadow(radius: 4, y: 2)
    }
}
