//
//  NotificationModifier.swift
//  SwiftUITest
//
//  Created by Илья Аникин on 03.08.2024.
//

import SwiftUI

public extension View {
    func notification<Content: View>(
        isPresented: Binding<Bool>,
        expiration: NotificationPresenter.Expiration = .timeout(.seconds(3)),
        content: @escaping () -> Content
    ) -> some View {
        modifier(
            NotificationModifier(
                isPresented: isPresented,
                expiration: expiration,
                notification: content
            )
        )
    }
}

struct NotificationModifier<Overlay: View>: ViewModifier {
    @Environment(NotificationPresenter.self) private var presenter
    
    @Binding var isPresented: Bool
    let expiration: NotificationPresenter.Expiration
    let notification: () -> Overlay
    
    @State private var notificationId = UUID()
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) {
                if isPresented {
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
            .onChange(of: presenter.stack) {
                if presenter.stack.find(notificationId) == nil {
                    withAnimation(presenter.removalAnimation) { isPresented = false }
                }
            }
    }
}
