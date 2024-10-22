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
    /// To create a popup you provide a view to display and specify its behaviour when user taps outside of the popup itself.
    /// You can specify which of *safe area* insets will be ignored by a view when displaying.
    /// Note that the background of fullscreen ignores this setting and fills the screen space entirely.
    /// Also you can configure a *outTapBehavior* to dismiss a popup when  user tap outside the popup itself.
    ///
    /// - Parameters:
    ///    - isPresented: A binding to a Boolean value that determines whether
    ///  to present the view that you create in the modifier's `content` closure.
    ///    - outTapBehavior: Determines popup's behaviour on user's taps ouyside the popup.
    ///    - ignoresEdges: A set of safe area edges to be ignored by the *content*.
    ///    - content: A closure that returns the content of the popup.
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
    /// To create a popup you provide a view to display and specify its behaviour when user taps outside of the popup itself.
    /// You can specify which of *safe area* insets will be ignored by a view when displaying.
    /// Note that the background of fullscreen ignores this setting and fills the screen space entirely.
    /// Also you can configure a *outTapBehavior* to dismiss a popup when  user tap outside the popup itself.
    ///
    /// - Parameters:
    ///    - item: An optional value that determines whether
    ///  to present the view that you create in the modifier's `content` closure.
    ///    - outTapBehavior: Determines popup's behaviour on user's taps ouyside the popup.
    ///    - ignoresEdges: A set of safe area edges to be ignored by the *content*.
    ///    - content: A closure that returns the content of the popup.
    ///
    /// - Note: Requires a ``View/popupRoot(:_)`` been called higher up the view hierarchy.
    ///
    func popup<Content: View, Item>(
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
    
    /// Presents a popup alert with **PopupKit**, with style and behaviour similar to system **alert()**.
    ///
    /// Popup alert is a modal window, that displaying some message or cutom content and requires a user
    /// to pick one of given actions.
    ///
    /// Popup alert wraps its actions in `ScrollView` automatically when its overral height is overlapping
    /// its preferred frame.
    ///
    /// - Parameters:
    ///    - isPresented: A `Bool` value that determines whether
    ///  to present the view that you create in the modifier's `content` closure.
    ///    - content: A closure that returns the content of the popup.
    ///    - actions: A closure that returns a set of actions to suggest to the user.
    ///
    /// - Note: Requires a ``View/popupRoot(:_)`` been called higher up the view hierarchy.
    /// - Important: Though popup alert supports custom content, it is intended to be used with staticaly sized content
    /// with height up to 300 pt.
    ///
    func popupAlert<Content: View>(
        isPresented: Binding<Bool>,
        content: @escaping () -> Content,
        actions: @escaping () -> [Action]
    ) -> some View {
        popup(
            isPresented: isPresented,
            outTapBehavior: .none,
            ignoresEdges: [],
            content: {
                AlertView(content: content, actions: actions)
            }
        )
    }
    
    /// Presents a popup alert with **PopupKit**, with style and behaviour similar to system **alert()**.
    ///
    /// Popup alert is a modal window, that displaying some message or cutom content and requires a user
    /// to pick one of given actions.
    ///
    /// Popup alert wraps its actions in `ScrollView` automatically when its overral height is overlapping
    /// its preferred frame.
    ///
    /// - Parameters:
    ///    - item: An optional value that determines whether
    ///  to present the view that you create in the modifier's `content` closure.
    ///    - content: A closure that returns the content of the popup.
    ///    - actions: A closure that returns a set of actions to suggest to the user.
    ///
    /// - Note: Requires a ``View/popupRoot(:_)`` been called higher up the view hierarchy.
    /// - Important: Though popup alert supports custom content, it is intended to be used with staticaly sized content
    /// with height up to 300 pt.
    ///
    func popupAlert<Content: View, Item>(
        item: Binding<Item?>,
        content: @escaping (Item) -> Content,
        actions: @escaping () -> [Action]
    ) -> some View {
        popupAlert(
            isPresented: Binding(
                get: { item.wrappedValue != nil },
                set: { if !$0 { item.wrappedValue = nil } }
            ),
            content: {
                Group {
                    if let wrapped = item.wrappedValue {
                        content(wrapped)
                    } else {
                        EmptyView()
                    }
                }
            },
            actions: actions
        )
    }
    
    /// Presents a popup alert with **PopupKit**, with style and behaviour similar to system **alert()**.
    ///
    /// Popup alert is a modal window, that displaying some message or cutom content and requires a user
    /// to pick one of given actions.
    ///
    /// Popup alert wraps its actions in `ScrollView` automatically when its overral height is overlapping
    /// its preferred frame.
    ///
    /// - Parameters:
    ///    - isPresented: A `Bool` value that determines whether
    ///  to present the view that you create in the modifier's `content` closure.
    ///    - title: An optional title for the alert.
    ///    - msg: An optional message for the alert
    ///    - actions: A closure that returns a set of actions to suggest to the user.
    ///
    /// - Note: Requires a ``View/popupRoot(:_)`` been called higher up the view hierarchy.
    ///
    func popupAlert(
        isPresented: Binding<Bool>,
        title: String? = nil,
        msg: String? = nil,
        actions: @escaping () -> [Action]
    ) -> some View {
        popup(
            isPresented: isPresented,
            outTapBehavior: .none,
            ignoresEdges: [],
            content: {
                AlertView(title: title, msg: msg, actions: actions)
            }
        )
    }
    
    /// Presents a popup alert with **PopupKit**, with style and behaviour similar to system **alert()**.
    ///
    /// Popup alert is a modal window, that displaying some message or cutom content and requires a user
    /// to pick one of given actions.
    ///
    /// Popup alert wraps its actions in `ScrollView` automatically when its overral height is overlapping
    /// its preferred frame.
    ///
    /// - Parameters:
    ///    - item: An optional value that determines whether
    ///  to present the view that you create in the modifier's `content` closure.
    ///    - title: An optional title for the alert.
    ///    - msg: An optional message for the alert
    ///    - actions: A closure that returns a set of actions to suggest to the user.
    ///
    /// - Note: Requires a ``View/popupRoot(:_)`` been called higher up the view hierarchy.
    ///
    func popupAlert<Item>(
        item: Binding<Item?>,
        title: String? = nil,
        msg: String? = nil,
        actions: @escaping () -> [Action]
    ) -> some View {
        popupAlert(
            isPresented: Binding(
                get: { item.wrappedValue != nil },
                set: { if !$0 { item.wrappedValue = nil } }
            ),
            title: title,
            msg: msg,
            actions: actions
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
