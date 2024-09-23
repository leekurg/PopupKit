//
//  ConfirmPresenter.swift
//  PopupKit
//
//  Created by Илья Аникин on 23.09.2024.
//

import SwiftUI

public final class ConfirmPresenter: ObservableObject {
    let isVerbose: Bool

    @Published public private(set) var presented: ConfirmEntry?
    
    public let insertionAnimation: Animation
    public let removalAnimation: Animation
    
    public init(
        verbose: Bool = false,
        insertAnimation: Animation = .spring(duration: 0.3),
        removeAnimation: Animation = .spring(duration: 0.3)
    ) {
        self.isVerbose = verbose
        self.insertionAnimation = insertAnimation
        self.removalAnimation = removeAnimation
    }
    
    /// Present a presentable entry with given **id** and **content**.
    ///
    /// - Returns: Returns **true** is this dialog was presented, otherwise returns **false**.
    ///
    @discardableResult func present<Content: View, S: ShapeStyle>(
        animated: Bool = true,
        background: S,
        cornerRadius: Double = 20.0,
        content: @escaping () -> Content,
        actions: () -> [Action]
    ) -> Bool {
        guard presented == nil else {
            dprint(isVerbose, "⚠️ confirm dialog is already presented - skip")
            return false
        }

        presented = .init(view: AnyView(content()), actions: actions())

        return true
    }
    
    /// Dismiss a currently presented entry.
    public func dismiss(animated: Bool = true) {
        guard let _ = presented else {
            dprint(isVerbose, "⚠️ no confirm dialogs is presented - skip")
            return
        }
        
        withAnimation(animated ? removalAnimation : nil) {
            presented = nil
            dprint(isVerbose, "🙈 dismissed")
        }
    }
    
    /// Returns **true** if confirm entry is currently presented.
    public func isPresented() -> Bool {
        presented != nil
    }
}

public extension ConfirmPresenter {
    /// Represents a presentable entry.
    struct ConfirmEntry: Equatable {
        let id: UUID
        /// Entry's content
        public let view: AnyView
        /// Regular actions
        public let actions: [Action]
        /// Cancel actions
        public let cancelActions: [Action]
        
        public init(
            view: AnyView,
            actions: [Action],
            cancelActions: [Action]
        ) {
            self.id = UUID()
            self.view = view
            self.actions = actions
            self.cancelActions = cancelActions
        }
        
        public init(
            view: AnyView,
            actions: [Action]
        ) {
            self.id = UUID()
            self.view = view
            
            let preprocessed = Self.preprocess(actions)
            self.actions = preprocessed.regular
            self.cancelActions = preprocessed.cancel
        }
        
        static func preprocess(_ actions: [Action]) -> (regular: [Action], cancel: [Action]) {
            let regular = actions.filter { $0.kind != .cancel }
            let cancel = actions.filter { $0.kind == .cancel }
            
            return (regular, cancel.isEmpty ? [.default] : cancel)
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
    }
}
