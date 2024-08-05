//
//  NotificationPresenter.swift
//  SwiftUITest
//
//  Created by Илья Аникин on 03.08.2024.
//

import Combine
import SwiftUI

@Observable public class NotificationPresenter {
    let isVerbose: Bool

    public private(set) var stack: [StackEntry] = []
    
    private var topEntryTimer: EntryTimer?
    
    public init(verbose: Bool = false) {
        self.isVerbose = verbose
    }
    
    /// Present a *content* with given **id**.
    ///
    /// - Returns: Returns presenting 'Destination' or **nil** when **id** is in stack already.
    ///
    public func present<Content: View>(
        id: UUID,
        expiration: Expiration,
        removalAnimation: Animation,
        content: @escaping () -> Content
    ) -> UUID? {
        if let _ = stack.find(id) {
            dprint(isVerbose, "⚠️ id \(id) is already in stack - skip")
            return nil
        }
        
        topEntryTimer = nil
        
        stack.append(
            StackEntry(
                id: id,
                deep: (stack.last?.deep ?? -1) + 1,
                expiration: expiration,
                view: AnyView(content())
            )
        )
        
        switch expiration {
        case .never: break
        case .timeout(let stride):
            topEntryTimer = makeTimer(
                forId: id,
                interval: stride.timeInterval,
                dismissAnimation: removalAnimation
            )
            dprint(isVerbose, "⏱️ sheduled \(id) in \(stride.timeInterval)s")
        }

        dprint(isVerbose, "✅ presenting \(id)")
        return id
    }
    
    public func dismiss(_ id: UUID, nextDismissAnimation: Animation?) {
        let presentedIndex = stack.firstIndex { $0.id == id }
        guard let presentedIndex else {
            dprint(isVerbose, "⚠️ id \(id) is not found in stack - skip")
            return
        }
        
        if id == stack.last?.id {
            stack.removeLast()
            dprint(isVerbose, "🙈 dismissed \(id)")
            
            if let newTopEntry = stack.last {
                switch newTopEntry.expiration {
                case .timeout(let stride):
                    topEntryTimer = makeTimer(
                        forId: newTopEntry.id,
                        interval: stride.timeInterval,
                        dismissAnimation: nextDismissAnimation
                    )
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
    
    public func isStacked(_ id: UUID) -> Bool {
        stack.find(id) != nil
    }
    
    public func popToRoot() {
        topEntryTimer = nil
        stack.removeAll()
    }
    
    private func makeTimer(forId id: UUID, interval: TimeInterval, dismissAnimation: Animation?) -> EntryTimer {
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
                    withAnimation(dismissAnimation) {self?.dismiss(id, nextDismissAnimation: dismissAnimation) }
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

func dprint(_ verbose: Bool?, _ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    if verbose != false {
        print(items, separator: separator, terminator: terminator)
    }
    #endif
}
