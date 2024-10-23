//
//  EnvironmentValues.swift
//  PopupKit
//
//  Created by Илья Аникин on 24.09.2024.
//

import SwiftUI

public extension EnvironmentValues {
    var popupActionTint: Color {
        get { self[ActionTintColorKey.self] }
        set { self[ActionTintColorKey.self] = newValue }
    }

    var popupActionFonts: ActionFonts {
        get { self[ActionFontsKey.self] }
        set { self[ActionFontsKey.self] = newValue }
    }
}

public extension View {
    /// Overrides text `foregroundColor` for underling **PopoupKit**'s confirmation dialogs.
    @ViewBuilder
    func popupActionTint(_ color: Color?) -> some View {
        if let color {
            environment(\.popupActionTint, color)
        } else {
            self
        }
    }

    /// Overrides text `Font` for underling **PopoupKit**'s confirmation dialog actions.
    @ViewBuilder
    func popupActionFonts(regular: Font? = nil, cancel: Font? = nil) -> some View {
        let fonts: ActionFonts = .init(
            regular: regular ?? ActionFontsKey.defaultValue.regular,
            cancel: cancel ?? ActionFontsKey.defaultValue.cancel
        )

        environment(\.popupActionFonts, fonts)
    }
}

fileprivate struct ActionTintColorKey: EnvironmentKey {
    static let defaultValue: Color = .primary
}

fileprivate struct ActionFontsKey: EnvironmentKey {
    static let defaultValue: ActionFonts = .init(
        regular: .system(size: 18, weight: .regular),
        cancel: .system(size: 18, weight: .semibold)
    )
}
