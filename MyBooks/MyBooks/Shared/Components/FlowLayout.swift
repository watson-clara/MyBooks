//
//  FlowLayout.swift
//  MyBooks
//
//  Created by clarafication on 6/29/26.
//

import SwiftUI

struct FlowLayout<Content: View>: View {

    let spacing: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: spacing) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
