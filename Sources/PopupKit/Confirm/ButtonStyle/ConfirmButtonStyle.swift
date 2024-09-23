//
//  ConfirmButtonStyle.swift
//  PopupKit
//
//  Created by Илья Аникин on 24.09.2024.
//

import SwiftUI

/// Button style for confirmation dialog.
struct ConfirmButtonStyle: ButtonStyle {
    private let animation: Animation
    private let scale: CGFloat
    
    @Environment(\.colorScheme) var colorScheme

    init(animation: Animation, scale: CGFloat) {
        self.animation = animation
        self.scale = scale
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .compositingGroup()
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? pressedStyle : AnyShapeStyle(Color.clear))
            .animation(animation, value: configuration.isPressed)
    }
    
    var pressedStyle: AnyShapeStyle {
        AnyShapeStyle(colorScheme == .light ? Color.gray.opacity(0.2) : Color.white.opacity(0.2))
    }
}

extension ButtonStyle where Self == ConfirmButtonStyle {
    /// Button with configurable simple press animation (opacity + scale).
    static func confirm(
        _ animation: Animation = .spring(duration: 0.2),
        scale: CGFloat = 0.99
    ) -> Self {
        ConfirmButtonStyle(animation: animation, scale: scale)
    }
}

#Preview {
    Button("Example") { }
        .buttonStyle(.confirm())
}
