//
//  CoverPresenter.swift
//
//
//  Created by Илья Аникин on 24.08.2024.
//

import Combine
import SwiftUI

public class CoverPresenter: ObservableObject {
    let isVerbose: Bool

    @Published public private(set) var stack: [StackEntry] = []
    
    public let insertionAnimation: Animation
    public let removalAnimation: Animation
    
    public init(
        verbose: Bool = false,
        insertAnimation: Animation = .spring(duration: 0.3),
        removeAnimation: Animation = .easeIn(duration: 0.3)
    ) {
        self.isVerbose = verbose
        self.insertionAnimation = insertAnimation
        self.removalAnimation = removeAnimation
    }
    
    /// Present a presentable entry with given **id** and **content**.
    ///
    /// - Returns: Returns presenting **id** or **nil** when entry is in stack already.
    ///
    @discardableResult public func present<Content: View, S: ShapeStyle>(
        id: UUID,
        animated: Bool = true,
        modal: Modality,
        background: S,
        cornerRadius: Double = 20.0,
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
                    modal: modal,
                    view: AnyView(
                        content()
                            .frame(maxWidth: .infinity)
                            .background(background, in: Rectangle())
                            .cornerRadius(cornerRadius, corners: [.topLeft, .topRight])
                    )
                )
            )
        }

        dprint(isVerbose, "✅ presenting \(id)")
        return id
    }
    
    /// Dismiss a presentable entry with given **id**.
    public func dismiss(_ id: UUID, animated: Bool = true) {
        let presentedIndex = stack.firstIndex { $0.id == id }
        guard let presentedIndex else {
            dprint(isVerbose, "⚠️ id \(id) is not found in stack - skip")
            return
        }
        
        withAnimation(animated ? removalAnimation : nil) {
            if id == stack.last?.id {
                stack.removeLast()
                UIApplication.hideKeyboard()
                dprint(isVerbose, "🙈 dismissed \(id)")
            } else {
                stack.remove(at: presentedIndex)
                stack = stack.reindexDeep(from: presentedIndex)
                dprint(isVerbose, "🙈 dismissed \(id)")
            }
        }
    }
    
    /// Returns **true** if presentable entry with given **id** is present in the stack.
    public func isStacked(_ id: UUID) -> Bool {
        stack.find(id) != nil
    }
    
    public func isTop(_ id: UUID) -> Bool {
        id == stack.last?.id
    }
    
    /// Dismisses all enties within the stack.
    public func popToRoot(animated: Bool = true) {
        withAnimation(animated ? removalAnimation : nil) { stack.removeAll() }
    }
    
    /// Dismisses a presentable entry which is currently on top of the stack.
    public func popLast(animated: Bool = true) {
        if let lastId = stack.last?.id {
            dismiss(lastId, animated: animated)
        }
    }
}

// MARK: - Entities
public extension CoverPresenter {
    /// Represents a presentable entry in stack.
    struct StackEntry: Stackable {
        /// id of the entry
        public let id: UUID
        /// Deep level of the entry in stack
        public let deep: Int
        /// Modality of the entry
        public let modal: Modality
        /// Entry's content
        public let view: AnyView
    }
}

extension Array where Element == CoverPresenter.StackEntry {
    func reindexDeep(from: Index = 0) -> Self {
        self
            .enumerated()
            .map { index, entry in
                guard index >= from else { return entry }
                
                return Element(
                    id: entry.id,
                    deep: index,
                    modal: entry.modal,
                    view: entry.view
                )
            }
    }
}
