//
//  ConfirmPresenter.swift
//  PopupKit
//
//  Created by Илья Аникин on 23.09.2024.
//

import SwiftUI

public final class ConfirmPresenter: ObservableObject {
    let isVerbose: Bool

    @Published public private(set) var presented: Entry?

    public let insertionAnimation: Animation
    public let removalAnimation: Animation

    @State private var feedback = UIImpactFeedbackGenerator(style: .medium)

    public init(
        verbose: Bool = false,
        insertAnimation: Animation = .spring(duration: 0.3),
        removeAnimation: Animation = .spring(duration: 0.3)
    ) {
        self.isVerbose = verbose
        self.insertionAnimation = insertAnimation
        self.removalAnimation = removeAnimation
    }

    /// Present an entry if possible.
    ///
    /// - Returns: Returns **true** when presenting was successful, otherwise returns **false**.
    ///
    @discardableResult func present<Content: View>(
        animated: Bool = true,
        tint: Color,
        fonts: Action.Fonts,
        header: @escaping () -> Content,
        actions: () -> [Action]
    ) -> Bool {
        guard presented == nil else {
            dprint(isVerbose, "⚠️ confirm dialog is already presented - skip")
            return false
        }

        presented = .init(view: AnyView(header()), tint: tint, fonts: fonts, actions: actions())
        feedback.prepare()

        return true
    }

    /// Dismiss a currently presented entry.
    ///
    public func dismiss(animated: Bool = true, haptic: Bool = false) {
        guard let _ = presented else {
            dprint(isVerbose, "⚠️ no confirm dialogs is presented - skip")
            return
        }

        withAnimation(animated ? removalAnimation : nil) {
            presented = nil
            if haptic { feedback.impactOccurred(intensity: 0.5) }
            dprint(isVerbose, "🙈 dismissed")
        }
    }

    /// Returns **true** if there is a presented entry.
    public func isPresented() -> Bool {
        presented != nil
    }
}

public extension ConfirmPresenter {
    /// Represents a presentable entry.
    struct Entry: Equatable {
        let id: UUID
        /// Entry's content
        public let view: AnyView
        /// Tint color for actions
        public let tint: Color
        /// Actions fonts
        public let fonts: Action.Fonts
        /// Regular actions
        public let actions: [Action]
        /// Cancel actions
        public let cancelActions: [Action]

        public init(
            view: AnyView,
            tint: Color,
            fonts: Action.Fonts,
            actions: [Action]
        ) {
            self.id = UUID()
            self.view = view
            self.tint = tint
            self.fonts = fonts

            let preprecessed = actions.segregate()
            self.actions = preprecessed.regular
            self.cancelActions = preprecessed.cancel
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
    }
}
