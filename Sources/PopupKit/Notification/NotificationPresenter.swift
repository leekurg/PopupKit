//
//  NotificationPresenter.swift
//  PopupKit
//
//  Created by Илья Аникин on 03.08.2024.
//

import Combine
import SwiftUI

public class NotificationPresenter: ObservableObject {
    let isVerbose: Bool

    @Published public private(set) var stack: [StackEntry] = []
    
    public let insertionAnimation: Animation
    public let removalAnimation: Animation
    
    private var topEntryTimer: EntryTimer?
    
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
    @discardableResult public func present<Content: View>(
        id: UUID,
        expiration: ExpirationPolicy,
        animated: Bool = true,
        content: @escaping () -> Content
    ) -> UUID? {
        if let _ = stack.find(id) {
            dprint(isVerbose, "⚠️ id \(id) is already in stack - skip")
            return nil
        }
        
        topEntryTimer = nil
        
        withAnimation(animated ? insertionAnimation : nil) {
            stack.append(
                StackEntry(
                    id: id,
                    deep: (stack.last?.deep ?? -1) + 1,
                    expiration: expiration,
                    view: AnyView(content())
                )
            )
        }
        
        switch expiration {
        case .never: break
        case .timeout(let stride):
            topEntryTimer = makeTimer(forId: id, interval: stride.timeInterval)
            dprint(isVerbose, "⏱️ sheduled \(id) in \(stride.timeInterval)s")
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
                
                if let newTopEntry = stack.last {
                    switch newTopEntry.expiration {
                    case .timeout(let stride):
                        topEntryTimer = makeTimer(forId: newTopEntry.id, interval: stride.timeInterval)
                        dprint(isVerbose, "⏱️ sheduled new top entry \(newTopEntry.id) in \(stride.timeInterval)s")
                    case .never: break
                    }
                    
                }
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
        topEntryTimer = nil
        withAnimation(animated ? removalAnimation : nil) { stack.removeAll() }
    }
    
    /// Dismisses a notification which is currently on top of the stack.
    public func popLast(animated: Bool = true) {
        if let lastId = stack.last?.id {
            topEntryTimer = nil
            dismiss(lastId, animated: animated)
        }
    }
    
    private func makeTimer(forId id: UUID, interval: TimeInterval) -> EntryTimer {
        EntryTimer(
            notificationId: id,
            timerCancellable: Timer
                .publish(
                    every: interval,
                    tolerance: 0.2,
                    on: RunLoop.main,
                    in: .default
                )
                .autoconnect()
                .first()
                .sink { [weak self] _ in
                    dprint(self?.isVerbose, "⏱️ timeout for id \(id)")
                    self?.dismiss(id, animated: true)
                }
        )
    }
}

// MARK: - Entities
public extension NotificationPresenter {
    /// Represents a notification entry in notifications stack.
    struct StackEntry: Stackable {
        /// id of the notification
        public let id: UUID
        /// Deep level of the notification in stack
        public let deep: Int
        /// Expiration policy for notification
        public let expiration: ExpirationPolicy
        /// Content on notification's view
        public let view: AnyView
    }
    
    /// Expiration timer entry, related to a specific notification by **id**.
    struct EntryTimer {
        let notificationId: UUID
        let timerCancellable: AnyCancellable
    }
}

extension Array where Element == NotificationPresenter.StackEntry {
    func reindexDeep(from: Index = 0) -> Self {
        self
            .enumerated()
            .map { index, entry in
                guard index >= from else { return entry }
                
                return Element(
                    id: entry.id,
                    deep: index,
                    expiration: entry.expiration,
                    view: entry.view
                )
            }
    }
}
