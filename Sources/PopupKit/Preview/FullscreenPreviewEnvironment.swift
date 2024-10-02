//
//  FullscreenPreviewEnvironment.swift
//
//
//  Created by Илья Аникин on 23.08.2024.
//

import SwiftUI

struct FullscreenPreviewEnvironment: ViewModifier {
    #if DEBUG
    @StateObject var presenter = FullscreenPresenter()
    #endif

    func body(content: Content) -> some View {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .fullscreenRoot()
                .environmentObject(presenter)
        } else {
            content
        }
        #else
        content
        #endif
    }
}
