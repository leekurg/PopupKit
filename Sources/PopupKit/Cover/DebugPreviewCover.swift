//
//  DebugPreviewCover.swift
//
//
//  Created by Илья Аникин on 25.08.2024.
//

import SwiftUI

public extension View {
    /// Injects a ``NotificationPresenter`` instance into `SwiftUI` environment and attach a
    /// ``NotificationRootModifier`` to a view when running in SwiftUI preview context.
    ///
    /// Use this modifier to prevent a `SwiftUI` Preview system from crashing when there is some calls to ``NotificationPresenter``
    /// down the view hierarchy. It modifies view hierarchy in a safe way and **only** for SwiftUI Preview context. You can attach it
    /// to your view within **@Preview** macro, for example.
    ///
    func debugPreviewCoverEnv(ignoresSafeAreaEdges: Edge.Set = []) -> some View {
        modifier(DebugPreviewCover(ignoresSafeAreaEdges: ignoresSafeAreaEdges))
    }
}

struct DebugPreviewCover: ViewModifier {
    #if DEBUG
    @StateObject var presenter = CoverPresenter()
    #endif
    
    let ignoredSafeAreaEdges: Edge.Set
    
    init(ignoresSafeAreaEdges: Edge.Set) {
        ignoredSafeAreaEdges = ignoresSafeAreaEdges
    }

    func body(content: Content) -> some View {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            content
                .coverRoot()
                .ignoresSafeArea(.all, edges: ignoredSafeAreaEdges)
                .environmentObject(presenter)
        } else {
            content
        }
        #else
        content
        #endif
    }
}
