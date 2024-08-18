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
    public func present<Content: View>(
        id: UUID,
        expiration: Expiration,
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
    
    public func isStacked(_ id: UUID) -> Bool {
        stack.find(id) != nil
    }
    
    public func popToRoot(animated: Bool = true) {
        topEntryTimer = nil
        withAnimation(animated ? removalAnimation : nil) { stack.removeAll() }
    }
    
    public func popLast(animated: Bool = true) {
        if let lastId = stack.last?.id {
            topEntryTimer = nil
            dismiss(lastId, animated: animated)
        }
    }
    
    private func makeTimer(forId id: UUID, interval: TimeInterval) -> EntryTimer {
        EntryTimer(
            entryId: id,
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

public extension NotificationPresenter {
    struct StackEntry: Identifiable, Equatable {
        public let id: UUID
        public let deep: Int
        public let expiration: Expiration
        public let view: AnyView
        
        public static func == (lhs: StackEntry, rhs: StackEntry) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    struct EntryTimer {
        let entryId: UUID
        let timerCancellable: AnyCancellable
    }
    
    enum Expiration {
        case never, timeout(RunLoop.SchedulerTimeType.Stride)
        
        var isTimeout: Bool {
            switch self {
            case .never: false
            case .timeout: true
            }
        }
    }
}

extension Array where Element == NotificationPresenter.StackEntry {
    func find(_ entryId: UUID) -> NotificationPresenter.StackEntry? {
        first { $0.id == entryId }
    }
    
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
