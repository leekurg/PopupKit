//
//  FullscreenRootModifier.swift
//
//
//  Created by Илья Аникин on 23.08.2024.
//

import SwiftUI

public extension View {
    func fullscreenRoot(_ transition: AnyTransition = .fullscreen) -> some View {
        modifier(FullscreenRootModifier(transition: transition))
    }
}

struct FullscreenRootModifier: ViewModifier {
    @EnvironmentObject private var presenter: FullscreenPresenter
    
    let transition: AnyTransition

    func body(content: Content) -> some View {
        content
            .overlay {
                if !presenter.stack.isEmpty {
                    ZStack {
                        ForEach(presenter.stack) { entry in
                            entry.view
                                .zIndex(Double(entry.deep))
                                .transition(transition)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(transition)
                }
            }
            .statusBarHidden(!presenter.stack.isEmpty)
    }
}
