//
//  CoverPreviewEnvironment 2.swift
//  PopupKit
//
//  Created by Илья Аникин on 17.10.2024.
//

import SwiftUI

struct PopupPreviewEnvironment: ViewModifier {
    #if DEBUG
    @StateObject var presenter = PopupPresenter()
    #endif
    
    let ignoredSafeAreaEdges: Edge.Set
    
    init(ignoresSafeAreaEdges: Edge.Set) {
        ignoredSafeAreaEdges = ignoresSafeAreaEdges
    }

    func body(content: Content) -> some View {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .popupRoot()
                .ignoresSafeArea(.container, edges: ignoredSafeAreaEdges)
                .environmentObject(presenter)
        } else {
            content
        }
        #else
        content
        #endif
    }
}
