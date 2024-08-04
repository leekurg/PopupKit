//
//  Environment.swift
//  SwiftUITest
//
//  Created by Илья Аникин on 03.08.2024.
//

import SwiftUI

public struct NotificationTransitionAnimation {
    public let insertion: Animation
    public let removal: Animation
}

public extension EnvironmentValues {
    var notificationTransitionAnimation: NotificationTransitionAnimation {
        get { self[NotificationTransitionAnimationKey.self] }
        set { self[NotificationTransitionAnimationKey.self] = newValue }
    }
}

struct NotificationTransitionAnimationKey: EnvironmentKey {
    static let defaultValue: NotificationTransitionAnimation = .init(
        insertion: .spring(duration: 0.5),
        removal: .spring(duration: 0.5)
     )
}
