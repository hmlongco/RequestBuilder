//
//  GroupedSectionViews.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 9/23/22.
//

import SwiftUI

struct GroupedScrollView<Content:View>: View {
    let content: () -> Content
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        ScrollView {
            content()
        }
        .background(Color(.systemGroupedBackground))
    }
}


struct GroupedSectionView<Content:View>: View {
    let content: () -> Content
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        LazyVStack {
            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(16)
    }
}

struct GroupedDisclosureView<Content:View>: View {
    let content: () -> Content
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        HStack {
            content()
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .accentColor(Color(UIColor.label))
        .padding(.vertical, 4)
    }
}
