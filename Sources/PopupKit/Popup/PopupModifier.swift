//
//  SwiftUIView.swift
//  PopupKit
//
//  Created by Илья Аникин on 17.10.2024.
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
    func popup<Content: View>(
        isPresented: Binding<Bool>,
        outTapBehavior: PopupPresenter.OutTapBehavior = .none,
        ignoresEdges: Edge.Set = [],
        content: @escaping () -> Content
    ) -> some View {
        #if DISABLE_POPUPKIT_IN_PREVIEWS
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            self
        } else {
            modifier(
                PopupModifier(
                    isPresented: isPresented,
                    outTapBehavior: outTapBehavior,
                    ignoresEdges: ignoresEdges,
                    popup: content
                )
            )
        }
        #else
        modifier(
            PopupModifier(
                isPresented: isPresented,
                outTapBehavior: outTapBehavior,
                ignoresEdges: ignoresEdges,
                popup: content
            )
        )
        #endif
    }
    
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
    ///    - item: An `Identifiable?` value that determines whether
    ///  to present the view that you create in the modifier's `content` closure.
    ///    - background: Background style of the presentable view.
    ///    - ignoresEdges: A set of safe area edges to be ignored by the *content*.
    ///    - dismissalScroll: A view behavoiur on scrolling down.
    ///    - content: A closure that returns the content of the notification.
    ///
    /// - Note: Requires a ``View/fullscreenRoot(:_)`` been called higher up the view hierarchy.
    ///
//    func fullscreen<Content: View, Style: ShapeStyle, Item: Identifiable>(
//        item: Binding<Item?>,
//        background: Style = .background,
//        ignoresEdges: Edge.Set = [],
//        dismissalScroll: DismissalScroll = .dismiss(predictedThreshold: 500),
//        content: @escaping (Item) -> Content
//    ) -> some View {
//        fullscreen(
//            isPresented: Binding(
//                get: { item.wrappedValue != nil },
//                set: { if !$0 { item.wrappedValue = nil } }
//            ),
//            background: background,
//            ignoresEdges: ignoresEdges,
//            dismissalScroll: dismissalScroll,
//            content: {
//                Group {
//                    if let wrapped = item.wrappedValue {
//                        content(wrapped)
//                    } else {
//                        EmptyView()
//                    }
//                }
//            }
//        )
//    }
}

struct PopupModifier<T: View>: ViewModifier {
    @EnvironmentObject private var presenter: PopupPresenter
    
    @Binding var isPresented: Bool
    let outTapBehavior: PopupPresenter.OutTapBehavior
    let ignoresEdges: Edge.Set
    let popup: () -> T
    
    @State private var popupId = UUID()
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { presented in
                if presented {
                    dprint(presenter.isVerbose, "popup [\(popupId)]: present me 🤲")
                    let presentedId = presenter.present(
                        id: popupId,
                        ignoresEdges: ignoresEdges,
                        outTapBehavior: outTapBehavior,
                        content: popup
                    )
                    if presentedId == nil { isPresented = false }
                } else {
                    if presenter.isStacked(popupId) {
                        dprint(presenter.isVerbose, "popup[\(popupId)]: dismiss me 🫠")
                        presenter.dismiss(popupId)
                    }
                }
            }
            .onChange(of: presenter.stack) { stack in
                Task {
                    if stack.find(popupId) == nil { isPresented = false }
                }
            }
    }
}
