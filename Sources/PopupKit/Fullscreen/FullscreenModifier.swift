//
//  FullscreenModifier.swift
//
//
//  Created by Илья Аникин on 23.08.2024.
//

import SwiftUI

public extension View {
    /// Presents a fullscreen with **PopupKit**.
    ///
    /// Fullscreen is similar to system *fullscreenCover*. Fullscreen covers the screen space entirely.
    /// Fullscreen respects device's safe area and provides a way to manage it.
    ///
    /// To create a fullscreen you provide a view to display and a background style.
    /// You can specify which of *safe area* insets will be ignored by a view when displaying.
    /// Note that the background of fullscreen ignores this setting and fills the screen space entirely.
    /// Also you can configure a *dismiss-on-scroll* behavoiur (``DismissalScroll``) - provide an appropriate
    /// translation needed for fullscreen to dismiss or disable this feature.
    ///
    /// - Parameters:
    ///    - isPresented: A binding to a Boolean value that determines whether
    ///  to present the view that you create in the modifier's `content` closure.
    ///    - background: Background style of the presentable view.
    ///    - ignoresEdges: A set of safe area edges to be ignored by the *content*.
    ///    - dismissalScroll: A view behavoiur on scrolling down.
    ///    - content: A closure that returns the content of the notification.
    ///
    /// - Note: Requires a ``View/fullscreenRoot(:_)`` been called higher up the view hierarchy.
    ///
    func fullscreen<Content: View, Style: ShapeStyle>(
        isPresented: Binding<Bool>,
        background: Style = .background,
        ignoresEdges: Edge.Set = [],
        dismissalScroll: DismissalScroll = .dismiss(predictedThreshold: 500),
        content: @escaping () -> Content
    ) -> some View {
        #if DISABLE_POPUPKIT_IN_PREVIEWS
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            self
        } else {
            modifier(
                FullscreenModifier(
                    isPresented: isPresented,
                    background: background,
                    ignoresEdges: ignoresEdges,
                    dismissalScroll: dismissalScroll,
                    fullscreen: content
                )
            )
        }
        #else
        modifier(
            FullscreenModifier(
                isPresented: isPresented,
                background: background,
                ignoresEdges: ignoresEdges,
                dismissalScroll: dismissalScroll,
                fullscreen: content
            )
        )
        #endif
    }
}

struct FullscreenModifier<T: View, S: ShapeStyle>: ViewModifier {
    @EnvironmentObject private var presenter: FullscreenPresenter
    
    @Binding var isPresented: Bool
    let background: S
    let ignoresEdges: Edge.Set
    let dismissalScroll: DismissalScroll
    let fullscreen: () -> T
    
    @State private var fullscreenId = UUID()
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { presented in
                if presented {
                    dprint(presenter.isVerbose, "overlay [\(fullscreenId)]: present me 🤲")
                    let presentedId = presenter.present(
                        id: fullscreenId,
                        background: background,
                        ignoresEdges: ignoresEdges,
                        dismissalScroll: dismissalScroll,
                        content: fullscreen
                    )
                    if presentedId == nil { isPresented = false }
                } else {
                    if presenter.isStacked(fullscreenId) {
                        dprint(presenter.isVerbose, "overlay[\(fullscreenId)]: dismiss me 🫠")
                        presenter.dismiss(fullscreenId)
                    }
                }
            }
            .onChange(of: presenter.stack) { stack in
                Task {
                    if stack.find(fullscreenId) == nil { isPresented = false }
                }
            }
    }
}
