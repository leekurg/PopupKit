//
//  NotificationModifier.swift
//  PopupKit
//
//  Created by Илья Аникин on 03.08.2024.
//

import SwiftUI

public extension View {
    @ViewBuilder func notification<Content: View>(
        isPresented: Binding<Bool>,
        expiration: NotificationPresenter.Expiration = .timeout(.seconds(3)),
        background: NotificationBackground = .none,
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
                    background: background,
                    notification: content
                )
            )
        }
        #else
        modifier(
            NotificationModifier(
                isPresented: isPresented,
                expiration: expiration,
                background: background,
                notification: content
            )
        )
        #endif
    }
}

struct NotificationModifier<T: View>: ViewModifier {
    @EnvironmentObject private var presenter: NotificationPresenter
    @State private var notificationId = UUID()
    
    @Binding var isPresented: Bool
    let expiration: NotificationPresenter.Expiration
    let background: NotificationBackground
    let notification: () -> T
    
    init(
        isPresented: Binding<Bool>,
        expiration: NotificationPresenter.Expiration,
        background: NotificationBackground,
        notification: @escaping () -> T
    ) {
        self._isPresented = isPresented
        self.expiration = expiration
        self.background = background
        self.notification = notification
    }
    
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
                            content: {
                                notification()
                                    .modifier(DefaultNotificationBackground(variant: background))
                            }
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
