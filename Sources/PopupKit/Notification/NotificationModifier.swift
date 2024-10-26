//
//  NotificationModifier.swift
//  PopupKit
//
//  Created by Илья Аникин on 03.08.2024.
//

import SwiftUI

public extension View {
    /// Presents a notification with PopupKit.
    ///
    /// - Parameters:
    ///    - isPresented: A binding to a Boolean value that determines whether
    ///  to present the notification that you create in the modifier's `content` closure.
    ///    - expiration: Notification's expiration policy.
    ///    - content: A closure that returns the content of the notification.
    ///
    /// - Note: Requires a ``View/notificationRoot(:_)`` been installed higher up the view hierarchy.
    ///
    @ViewBuilder func notification<Content: View>(
        isPresented: Binding<Bool>,
        expiration: ExpirationPolicy = .timeout(.seconds(3)),
        content: @escaping () -> Content
    ) -> some View {
        #if DISABLE_POPUPKIT_IN_PREVIEWS
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            self
        } else {
            modifier(
                NotificationModifier(
                    isPresented: isPresented,
                    expiration: expiration,
                    notification: content
                )
            )
        }
        #else
        modifier(
            NotificationModifier(
                isPresented: isPresented,
                expiration: expiration,
                notification: content
            )
        )
        #endif
    }

    /// Presents a notification with PopupKit.
    ///
    /// - Parameters:
    ///    - item: An `Identifiable?` value that determines whether
    ///  to present the notification that you create in the modifier's `content` closure.
    ///    - expiration: Notification's expiration policy.
    ///    - content: A closure that returns the content of the notification.
    ///
    /// - Note: Requires a ``View/notificationRoot(:_)`` been installed higher up the view hierarchy.
    ///
    @ViewBuilder func notification<Content: View, Item: Identifiable>(
        item: Binding<Item?>,
        expiration: ExpirationPolicy = .never,
        content: @escaping (Item) -> Content
    ) -> some View {
        notification(
            isPresented: Binding(
                get: { item.wrappedValue != nil },
                set: { if !$0 { item.wrappedValue = nil } }
            ),
            expiration: expiration,
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
    
    /// Presents a default-styled notification with PopupKit.
    ///
    /// - Parameters:
    ///    - item: An `Notification?` value that determines whether
    ///  to present the notification.
    ///    - expiration: Notification's expiration policy.
    ///
    /// - Note: Requires a ``View/notificationRoot(:_)`` been installed higher up the view hierarchy.
    ///
    @ViewBuilder func notification(
        item: Binding<Notification?>,
        expiration: ExpirationPolicy = .never
    ) -> some View {
        notification(
            item: item,
            expiration: expiration
        ) { item in
            NotificationView(notification: item)
        }
    }
}

struct NotificationModifier<T: View>: ViewModifier {
    @EnvironmentObject private var presenter: NotificationPresenter
    @State private var notificationId = UUID()
    
    @Binding var isPresented: Bool
    let expiration: ExpirationPolicy
    let notification: () -> T
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { presented in
                if presented {
                    dprint(presenter.isVerbose, "notification [\(notificationId)]: present me 🤲")
                    var presentedId: UUID?
                    withAnimation(presenter.insertionAnimation) {
                        presentedId = presenter.present(
                            id: notificationId,
                            expiration: expiration,
                            content: notification
                        )
                    }
                    if presentedId == nil { isPresented = false }
                } else {
                    if presenter.isStacked(notificationId) {
                        dprint(presenter.isVerbose, "notification [\(notificationId)]: dismiss me 🫠")
                        presenter.dismiss(notificationId)
                    }
                }
            }
            .onChange(of: presenter.stack) { stack in
                if stack.find(notificationId) == nil {
                    withAnimation(presenter.removalAnimation) { isPresented = false }
                }
            }
    }
}
