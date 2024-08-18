//
//  NotificationModifier.swift
//  PopupKit
//
//  Created by Илья Аникин on 03.08.2024.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func notification<Content: View>(
        isPresented: Binding<Bool>,
        expiration: NotificationPresenter.Expiration = .timeout(.seconds(3)),
        content: @escaping () -> Content
    ) -> some View {
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
    }
}

struct NotificationModifier<Overlay: View>: ViewModifier {
    @EnvironmentObject private var presenter: NotificationPresenter
    
    @Binding var isPresented: Bool
    let expiration: NotificationPresenter.Expiration
    let notification: () -> Overlay
    
    @State private var notificationId = UUID()
    
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
