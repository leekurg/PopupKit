//
//  FullscreenPresenter.swift
//
//
//  Created by Илья Аникин on 23.08.2024.
//

import Foundation
import SwiftUI

public final class FullscreenPresenter: ObservableObject {
    @Published public private(set) var stack: [StackEntry] = []
    
    public let insertionAnimation: Animation
    public let removalAnimation: Animation

    let isVerbose: Bool    
    
    public init(
        verbose: Bool = false,
        insertAnimation: Animation = .spring(duration: 0.5),
        removeAnimation: Animation = .spring(duration: 0.5)
    ) {
        self.isVerbose = verbose
        self.insertionAnimation = insertAnimation
        self.removalAnimation = removeAnimation
    }
    
    /// Present a *content* with given **id**.
    ///
    /// - Returns: Returns presenting 'Destination' or **nil** when **id** is in stack already.
    ///
    public func present<Content: View, S: ShapeStyle>(
        id: UUID,
        animated: Bool = true,
        background: S,
        ignoresEdges: Edge.Set,
        dismissalScroll: DismissalScroll,
        content: @escaping () -> Content
    ) -> UUID? {
        if let _ = stack.find(id) {
            dprint(isVerbose, "⚠️ id \(id) is already in stack - skip")
            return nil
        }
        
        withAnimation(animated ? insertionAnimation : nil) {
            stack.append(
                StackEntry(
                    id: id,
                    deep: (stack.last?.deep ?? -1) + 1,
                    view: AnyView(content()),
                    background: AnyShapeStyle(background),
                    ignoresEdges: ignoresEdges,
                    dismissalScroll: dismissalScroll
                )
            )
        }

        dprint(isVerbose, "✅ presenting \(id)")
        return id
    }
    
    public func dismiss(_ id: UUID, animated: Bool = true) {
        let presentedIndex = stack.firstIndex { $0.id == id }
        guard let presentedIndex else {
            dprint(isVerbose, "⚠️ id \(id) is not found in stack - skip")
            return
        }
        
        withAnimation(animated ? removalAnimation : nil) {
            let _ = stack.remove(at: presentedIndex)
        }

        dprint(isVerbose, "🙈 dismiss \(id)")
    }
    
    /// Returns **true** if presentable entry with given **id** is presented in the stack.
    public func isStacked(_ id: UUID) -> Bool {
        stack.find(id) != nil
    }
    
    public func isTop(_ id: UUID) -> Bool {
        id == stack.last?.id
    }
    
    /// Dismisses all presentable entries within the stack.
    public func popToRoot(animated: Bool = true) {
        withAnimation(animated ? removalAnimation : nil) { stack.removeAll() }
    }
    
    /// Dismisses a stack's top presentable entry.
    public func popLast(animated: Bool = true) {
        if let lastId = stack.last?.id {
            dismiss(lastId, animated: animated)
        }
    }
}

public extension FullscreenPresenter {
    struct StackEntry: Stackable {
        public let id: UUID
        public let deep: Int
        public let view: AnyView
        public let background: AnyShapeStyle
        public let ignoresEdges: Edge.Set
        public let dismissalScroll: DismissalScroll
    }
}
