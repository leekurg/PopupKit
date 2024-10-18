//
//  SwiftUIView.swift
//  PopupKit
//
//  Created by Илья Аникин on 17.10.2024.
//

import SwiftUI

public extension View {
    /// Presents a popup with **PopupKit**.
    ///
    /// Popup is a modal window, that displaying some information or requires an action.
    /// Popup respects device's safe area and provides a way to manage it.
    ///
    /// To create a popup you provide a view to display and specify its behaviour when user taps outside of the popup itesel.
    /// You can specify which of *safe area* insets will be ignored by a view when displaying.
    /// Note that the background of fullscreen ignores this setting and fills the screen space entirely.
    /// Also you can configure a *outTapBehavior* to dismiss a popup when  user tap outside the popup itself.
    ///
    /// - Parameters:
    ///    - isPresented: A binding to a Boolean value that determines whether
    ///  to present the view that you create in the modifier's `content` closure.
    ///    - outTapBehavior: Determines popup's behaviour on user's taps ouyside the popup.
    ///    - ignoresEdges: A set of safe area edges to be ignored by the *content*.
    ///    - content: A closure that returns the content of the notification.
    ///
    /// - Note: Requires a ``View/popupRoot(:_)`` been called higher up the view hierarchy.
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
    
    /// Presents a popup with **PopupKit**.
    ///
    /// Popup is a modal window, that displaying some information or requires an action.
    /// Popup respects device's safe area and provides a way to manage it.
    ///
    /// To create a popup you provide a view to display and specify its behaviour when user taps outside of the popup itesel.
    /// You can specify which of *safe area* insets will be ignored by a view when displaying.
    /// Note that the background of fullscreen ignores this setting and fills the screen space entirely.
    /// Also you can configure a *outTapBehavior* to dismiss a popup when  user tap outside the popup itself.
    ///
    /// - Parameters:
    ///    - item: An optional value that determines whether
    ///  to present the view that you create in the modifier's `content` closure.
    ///    - outTapBehavior: Determines popup's behaviour on user's taps ouyside the popup.
    ///    - ignoresEdges: A set of safe area edges to be ignored by the *content*.
    ///    - content: A closure that returns the content of the notification.
    ///
    /// - Note: Requires a ``View/popupRoot(:_)`` been called higher up the view hierarchy.
    ///
    func popup<Content: View, Style: ShapeStyle, Item>(
        item: Binding<Item?>,
        outTapBehavior: PopupPresenter.OutTapBehavior = .none,
        ignoresEdges: Edge.Set = [],
        content: @escaping (Item) -> Content
    ) -> some View {
        popup(
            isPresented: Binding(
                get: { item.wrappedValue != nil },
                set: { if !$0 { item.wrappedValue = nil } }
            ),
            outTapBehavior: outTapBehavior,
            ignoresEdges: ignoresEdges,
            content: {
                Group {
                    if let wrapped = item.wrappedValue {
                        content(wrapped)
                    } else {
                        EmptyView()
                    }
                }
            }
        )
    }
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
