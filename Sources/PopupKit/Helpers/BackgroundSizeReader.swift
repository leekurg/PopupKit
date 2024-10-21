//
//  BackgroundSizeReader.swift
//  PopupKit
//
//  Created by Илья Аникин on 21.10.2024.
//

import SwiftUI

/// A view modifier for observing size of a view.
///
/// Adds transparent view with GeometryReader to content's background
/// and write it's size changes to a *size* binding.
///
struct BackgroundSizeReader: ViewModifier {
    @Binding var size: CGSize

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: SizePreferenceKey.self,
                        value: geometry.size
                    )
                }
            )
            .onPreferenceChange(SizePreferenceKey.self) { self.size = $0 }
    }
}

private struct SizePreferenceKey: SwiftUI.PreferenceKey {
    static var defaultValue: CGSize { .zero }

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { }
}

public extension View {
    /// Adds a view modifier for observing size of a view.
    ///
    /// Adds transparent view with GeometryReader to content's background
    /// and write it's size changes to a *size* binding.
    func sizeReader(size: Binding<CGSize>) -> some View {
        self.modifier(BackgroundSizeReader(size: size))
    }
}
