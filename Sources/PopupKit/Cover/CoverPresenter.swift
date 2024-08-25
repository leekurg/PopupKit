//
//  CoverPresenter.swift
//
//
//  Created by Илья Аникин on 24.08.2024.
//

import Combine
import SwiftUI

//open class BasicPresenter<Entry: Stackable>: ObservableObject {
//    @Published var stack: [Entry] = []
//    
//    let insertionAnimation: Animation
//    let removalAnimation: Animation
//    
//    let isVerbose: Bool
//    
//    public init(
//        verbose: Bool = false,
//        insertAnimation: Animation = .spring(duration: 0.5),
//        removeAnimation: Animation = .spring(duration: 0.5)
//    ) {
//        self.isVerbose = verbose
//        self.insertionAnimation = insertAnimation
//        self.removalAnimation = removeAnimation
//    }
//    
//    /// Present a *content* with given **id**.
//    ///
//    /// - Returns: Returns presenting 'Destination' or **nil** when **id** is in stack already.
//    ///
//    open func present<Content: View>(
//        id: Entry.ID,
//        animated: Bool = true,
//        content: @escaping () -> Content
//    ) -> Entry.ID? {
//        if let _ = stack.find(id) {
//            dprint(isVerbose, "⚠️ id \(id) is already in stack - skip")
//            return nil
//        }
//
////        // makeNewEntry() method, that must be impleneted by clients
////        withAnimation(animated ? insertionAnimation : nil) {
////            stack.append(Entry(id: id, deep: (stack.last?.deep ?? -1) + 1, view: AnyView(content())))
////        }
//
//        dprint(isVerbose, "✅ presenting \(id)")
//        return id
//    }
//    
////    open func makeNewEntry()
//    
////    public func dismiss(_ id: UUID, animated: Bool = true) {
////        let presentedIndex = stack.firstIndex { $0.id == id }
////        guard let presentedIndex else {
////            dprint(isVerbose, "⚠️ id \(id) is not found in stack - skip")
////            return
////        }
////        
////        withAnimation(animated ? removalAnimation : nil) {
////            let _ = stack.remove(at: presentedIndex)
////        }
////
////        dprint(isVerbose, "🙈 dismiss \(id)")
////    }
////    
////    public func isStacked(_ id: UUID) -> Bool {
////        stack.find(id) != nil
////    }
////    
////    public func popToRoot() {
////        stack.removeAll()
////    }
////    
////    public func popFirst() {
////        stack.removeFirst()
////    }
////    
////    public func popLast() {
////        stack.removeLast()
////    }
//}

public class CoverPresenter: ObservableObject {
    let isVerbose: Bool

    @Published public private(set) var stack: [StackEntry] = []
    
    public let insertionAnimation: Animation
    public let removalAnimation: Animation
    
    public init(
        verbose: Bool = false,
        insertAnimation: Animation = .spring(duration: 0.5),
        removeAnimation: Animation = .spring(duration: 0.5)
    ) {
        self.isVerbose = verbose
        self.insertionAnimation = insertAnimation
        self.removalAnimation = removeAnimation
    }
    
    /// Present a notification with given **id** and **content**. Notification's dismiss behavour is defined by
    /// **expiration** policy.
    ///
    /// - Returns: Returns presenting 'Destination' or **nil** when **id** is in stack already.
    ///
    public func present<Content: View>(
        id: UUID,
        animated: Bool = true,
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
                    view: AnyView(content())
                )
            )
        }

        dprint(isVerbose, "✅ presenting \(id)")
        return id
    }
    
    /// Dismiss a notification with given **id**.
    public func dismiss(_ id: UUID, animated: Bool = true) {
        let presentedIndex = stack.firstIndex { $0.id == id }
        guard let presentedIndex else {
            dprint(isVerbose, "⚠️ id \(id) is not found in stack - skip")
            return
        }
        
        withAnimation(animated ? removalAnimation : nil) {
            if id == stack.last?.id {
                stack.removeLast()
                dprint(isVerbose, "🙈 dismissed \(id)")
            } else {
                stack.remove(at: presentedIndex)
                stack = stack.reindexDeep(from: presentedIndex)
                dprint(isVerbose, "🙈 dismissed \(id)")
            }
        }
    }
    
    /// Returns **true** if notification with given **id** is present in the stack.
    public func isStacked(_ id: UUID) -> Bool {
        stack.find(id) != nil
    }
    
    /// Dismisses all notifications within the stack.
    public func popToRoot(animated: Bool = true) {
        withAnimation(animated ? removalAnimation : nil) { stack.removeAll() }
    }
    
    /// Dismisses a notification which is currently on top of the stack.
    public func popLast(animated: Bool = true) {
        if let lastId = stack.last?.id {
            dismiss(lastId, animated: animated)
        }
    }
}

// MARK: - Entities
public extension CoverPresenter {
    /// Represents a notification entry in notifications stack.
    struct StackEntry: Stackable {
        /// id of the notification
        public let id: UUID
        /// Deep level of the notification in stack
        public let deep: Int
        /// Content on notification's view
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
                    view: entry.view
                )
            }
    }
}
