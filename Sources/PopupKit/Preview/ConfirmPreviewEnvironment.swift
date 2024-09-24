//
//  ConfirmPreviewEnvironment.swift
//  PopupKit
//
//  Created by Илья Аникин on 24.09.2024.
//

import SwiftUI

struct ConfirmPreviewEnvironment: ViewModifier {
    #if DEBUG
    @StateObject var presenter = ConfirmPresenter()
    #endif

    func body(content: Content) -> some View {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .confirmRoot()
                .environmentObject(presenter)
        } else {
            content
        }
        #else
        content
        #endif
    }
}
