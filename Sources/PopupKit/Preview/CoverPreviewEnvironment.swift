//
//  CoverPreviewEnvironment.swift
//
//
//  Created by Илья Аникин on 25.08.2024.
//

import SwiftUI

struct CoverPreviewEnvironment: ViewModifier {
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
