//
//  NotificationPreviewEnvironment.swift
//  PopupKit
//
//  Created by Илья Аникин on 18.08.2024.
//

import SwiftUI

struct NotificationPreviewEnvironment: ViewModifier {
    #if DEBUG
    @StateObject var notificationPresenter = NotificationPresenter()
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
                .notificationRoot()
                .ignoresSafeArea(.all, edges: ignoredSafeAreaEdges)
                .environmentObject(notificationPresenter)
        } else {
            content
        }
        #else
        content
        #endif
    }
}
