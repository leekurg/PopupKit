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
    
    private var timers: [UUID: AnyCancellable] = [:]
    
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
        
        switch expiration {
        case .never: break
        case .timeout(let stride):
            let timer = Just(id)
                .delay(for: stride, tolerance: 0.2, scheduler: RunLoop.main)
                .sink { [weak self] id in
                    dprint(self?.isVerbose, "⏱️ timeout for id \(id)")
                    withAnimation(removalAnimation) { self?.dismiss(id) }
                }
            
            timers[id] = timer
        }

        stack.append(StackEntry(id: id, deep: (stack.last?.deep ?? -1) + 1, view: AnyView(content())))
        dprint(isVerbose, "✅ presenting \(id)")
        return id
    }
    
    public func dismiss(_ id: UUID) {
        let presentedIndex = stack.firstIndex { $0.id == id }
        
        if let presentedIndex {
            stack.remove(at: presentedIndex)
            dprint(isVerbose, "🙈 dismiss \(id)")
        } else {
            dprint(isVerbose, "⚠️ id \(id) is not found in hierarchy - skip")
        }
    }
    
    public func isStacked(_ id: UUID) -> Bool {
        stack.find(id) != nil
    }
    
    public func popToRoot() {
        stack.removeAll()
    }
    
    public func popFirst() {
        stack.removeFirst()
    }
    
    public func popLast() {
        stack.removeLast()
    }
}

public extension NotificationPresenter {
    struct StackEntry: Identifiable, Equatable {
        public let id: UUID
        public let deep: Int
        public let view: AnyView
        
        public static func == (lhs: StackEntry, rhs: StackEntry) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    enum Expiration {
        case never, timeout(RunLoop.SchedulerTimeType.Stride)
    }
}

extension Array where Element == NotificationPresenter.StackEntry {
    func find(_ entryId: UUID) -> NotificationPresenter.StackEntry? {
        first { $0.id == entryId }
    }
}

func dprint(_ verbose: Bool?, _ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    if verbose != false {
        print(items, separator: separator, terminator: terminator)
    }
    #endif
}
