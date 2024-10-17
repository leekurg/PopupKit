//
//  AnyTransition+Extension.swift
//  PopupKit
//
//  Created by Илья Аникин on 18.08.2024.
//

import SwiftUI

public extension AnyTransition {
    static let cover: AnyTransition = .asymmetric(
        insertion: .move(edge: .bottom),
        removal: .move(edge: .bottom)
    )
    
    static let notificationTop: AnyTransition = .asymmetric(
        insertion: .move(edge: .top),
        removal: .move(edge: .top).combined(with: .opacity)
    )
    
    static let notificationBottom: AnyTransition = .asymmetric(
        insertion: .move(edge: .bottom),
        removal: .move(edge: .bottom).combined(with: .opacity)
    )
    
    static let popup: AnyTransition = .blur.combined(with: .scale(scale: 1.5))
}

struct BlurTransition: ViewModifier, Animatable {
    private var radius: Double

    init(radius: Double?) {
        self.radius = radius ?? 0
    }

    var animatableData: Double {
        get { radius }
        set { radius = newValue }
    }

    func body(content: Content) -> some View {
        content.blur(radius: radius)
    }
}

extension AnyTransition {
    static var blur: Self {
        blur()
    }

    static func blur(radius: Double? = 20) -> Self {
        AnyTransition.modifier(
            active: BlurTransition(radius: radius),
            identity: BlurTransition(radius: 0)
        )
        .combined(with: .opacity)
    }
}
