//
//  ConfirmButtonStyle.swift
//  PopupKit
//
//  Created by Илья Аникин on 24.09.2024.
//

import SwiftUI

/// Button style for confirmation dialog.
struct ConfirmButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? pressedStyle : AnyShapeStyle(Color.clear))
    }

    var pressedStyle: AnyShapeStyle {
        AnyShapeStyle(colorScheme == .light ? Color.gray.opacity(0.2) : Color.white.opacity(0.1))
    }
}

extension ButtonStyle where Self == ConfirmButtonStyle {
    /// Button with configurable simple press animation (opacity + scale).
    static var confirm: Self {
        ConfirmButtonStyle()
    }
}

#Preview {
    Button("Example") { }
        .buttonStyle(.confirm)
}
