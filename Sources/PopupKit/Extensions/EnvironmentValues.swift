//
//  EnvironmentValues.swift
//  PopupKit
//
//  Created by Илья Аникин on 24.09.2024.
//

import SwiftUI

extension EnvironmentValues {
    var confirmTint: Color {
        get { self[ConfirmTintColorKey.self] }
        set { self[ConfirmTintColorKey.self] = newValue }
    }

    var confirmFonts: ConfirmPresenter.Entry.Fonts {
        get { self[ConfirmFontsKey.self] }
        set { self[ConfirmFontsKey.self] = newValue }
    }
}

public extension View {
    /// Overrides text `foregroundColor` for underling **PopoupKit**'s confirmation dialogs.
    @ViewBuilder
    func confirmTint(_ color: Color?) -> some View {
        if let color {
            environment(\.confirmTint, color)
        } else {
            self
        }
    }

    /// Overrides text `Font` for underling **PopoupKit**'s confirmation dialog actions.
    @ViewBuilder
    func confirmFonts(regular: Font? = nil, cancel: Font? = nil) -> some View {
        let fonts: ConfirmPresenter.Entry.Fonts = .init(
            regular: regular ?? ConfirmFontsKey.defaultValue.regular,
            cancel: cancel ?? ConfirmFontsKey.defaultValue.cancel
        )

        environment(\.confirmFonts, fonts)
    }
}

fileprivate struct ConfirmTintColorKey: EnvironmentKey {
    static let defaultValue: Color = .primary
}

fileprivate struct ConfirmFontsKey: EnvironmentKey {
    static let defaultValue: ConfirmPresenter.Entry.Fonts = .init(
        regular: .system(size: 18, weight: .regular),
        cancel: .system(size: 18, weight: .semibold)
    )
}
