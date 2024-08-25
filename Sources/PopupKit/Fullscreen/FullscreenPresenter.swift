//
//  FullscreenPresenter.swift
//
//
//  Created by Илья Аникин on 23.08.2024.
//

import Foundation
import SwiftUI

//protocol Stackable2: Identifiable where ID: Hashable {
//    var id: ID { get }
//    var value: Int { get }
//}
//
//struct Foo: Stackable2 {
//    let id: UUID
//    let value: Int
//}

//class BasicPresenter<Entry: Stackable>: ObservableObject {
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
//    public func present<Content: View>(
//        id: Entry.ID,
//        animated: Bool = true,
//        content: @escaping () -> Content
//    ) -> Entry.ID? {
//        if let _ = stack.find(id) {
//            dprint(isVerbose, "⚠️ id \(id) is already in stack - skip")
//            return nil
//        }
//
//        // makeNewEntry() method, that must be impleneted by clients
//        withAnimation(animated ? insertionAnimation : nil) {
//            stack.append(Entry(id: id, deep: (stack.last?.deep ?? -1) + 1, view: AnyView(content())))
//        }
//
//        dprint(isVerbose, "✅ presenting \(id)")
//        return id
//    }
//    
//    public func dismiss(_ id: UUID, animated: Bool = true) {
//        let presentedIndex = stack.firstIndex { $0.id == id }
//        guard let presentedIndex else {
//            dprint(isVerbose, "⚠️ id \(id) is not found in stack - skip")
//            return
//        }
//        
//        withAnimation(animated ? removalAnimation : nil) {
//            let _ = stack.remove(at: presentedIndex)
//        }
//
//        dprint(isVerbose, "🙈 dismiss \(id)")
//    }
//    
//    public func isStacked(_ id: UUID) -> Bool {
//        stack.find(id) != nil
//    }
//    
//    public func popToRoot() {
//        stack.removeAll()
//    }
//    
//    public func popFirst() {
//        stack.removeFirst()
//    }
//    
//    public func popLast() {
//        stack.removeLast()
//    }
//}

//protocol PresenterProtocol: ObservableObject {
//    associatedtype StackEntry: Stackable
//
//    var stack: [StackEntry] { get }
//    
//    func dismiss(_ id: Stackable.ID, animated: Bool)
//}

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
            stack.append(StackEntry(id: id, deep: (stack.last?.deep ?? -1) + 1, view: AnyView(content())))
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
    }
}
