//
//  DebugPreviewFullscreen.swift
//
//
//  Created by Илья Аникин on 23.08.2024.
//

import SwiftUI

public extension View {
    /// Injects a ``FullscreenPresenter`` instance into `SwiftUI` environment and attach a
    /// ``FullscreenRootModifier`` to a view when running in SwiftUI preview context.
    ///
    /// Use this modifier to prevent a `SwiftUI` Preview system from crashing when there is some calls to ``FullscreenPresenter``
    /// down the view hierarchy. It modifies view hierarchy in a safe way and **only** for SwiftUI Preview context. You can attach it
    /// to your view within **@Preview** macro, for example.
    ///
    func debugPreviewFullscreenEnv(ignoresSafeAreaEdges: Edge.Set = []) -> some View {
        modifier(DebugPreviewFullscreen(ignoresSafeAreaEdges: ignoresSafeAreaEdges))
    }
}

struct DebugPreviewFullscreen: ViewModifier {
    #if DEBUG
    @StateObject var presenter = FullscreenPresenter()
    #endif
    
    let ignoredSafeAreaEdges: Edge.Set
    
    init(ignoresSafeAreaEdges: Edge.Set) {
        ignoredSafeAreaEdges = ignoresSafeAreaEdges
    }

    func body(content: Content) -> some View {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            content
                .fullscreenRoot()
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
