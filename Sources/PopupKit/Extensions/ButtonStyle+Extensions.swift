//
//  ButtonStyle+Extensions.swift
//  PopupKit
//
//  Created by Илья Аникин on 20.10.2024.
//

import SwiftUI

/// Button style for alerts and confirmation dialogs.
struct AlertButtonStyle: ButtonStyle {
    let context: ActionContext
    
    @Environment(\.colorScheme) var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: context.height)
            .background(configuration.isPressed ? pressedStyle : AnyShapeStyle(Color.clear))
    }

    var pressedStyle: AnyShapeStyle {
        AnyShapeStyle(colorScheme == .light ? Color.gray.opacity(0.2) : Color.white.opacity(0.1))
    }
}

extension ButtonStyle where Self == AlertButtonStyle {
    /// Button with configurable simple press animation (opacity + scale).
    static func alert(context: ActionContext) -> Self {
        AlertButtonStyle(context: context)
    }
}

#Preview {
    Button("Example") { }
        .buttonStyle(.alert(context: .alert))
        .border(.orange)
}
