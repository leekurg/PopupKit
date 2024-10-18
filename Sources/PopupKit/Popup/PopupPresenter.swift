//
//  PopupPresenter.swift
//  PopupKit
//
//  Created by Илья Аникин on 17.10.2024.
//


import Foundation
import SwiftUI

public final class PopupPresenter: ObservableObject {
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
    @discardableResult public func present<Content: View>(
        id: UUID,
        animated: Bool = true,
        ignoresEdges: Edge.Set,
        outTapBehavior: OutTapBehavior,
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
                    outTapBehavior: outTapBehavior,
                    ignoresEdges: ignoresEdges
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
            UIApplication.hideKeyboard()
            let _ = stack.remove(at: presentedIndex)
        }
        stack = stack.reindexDeep(from: presentedIndex)
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

public extension PopupPresenter {
    struct StackEntry: Stackable {
        public let id: UUID
        public let deep: Int
        public let view: AnyView
        public let outTapBehavior: OutTapBehavior
        public let ignoresEdges: Edge.Set
    }
    
    enum OutTapBehavior {
        case none
        case dismiss
    }
}

extension Array where Element == PopupPresenter.StackEntry {
    func reindexDeep(from: Index = 0) -> Self {
        self
            .enumerated()
            .map { index, entry in
                guard index >= from else { return entry }
                
                return Element(
                    id: entry.id,
                    deep: index,
                    view: entry.view,
                    outTapBehavior: entry.outTapBehavior,
                    ignoresEdges: entry.ignoresEdges
                )
            }
    }
}
