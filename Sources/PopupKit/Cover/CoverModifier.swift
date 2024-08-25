//
//  CoverModifier.swift
//
//
//  Created by Илья Аникин on 25.08.2024.
//

import SwiftUI

public extension View {
    /// Presents a notification with PopupKit.
    ///
    /// - Parameters:
    ///    - isPresented: A binding to a Boolean value that determines whether
    ///  to present the notification that you create in the modifier's `content` closure.
    ///    - expiration: Notification's expiration policy.
    ///    - background: Background variant.
    ///    - content: A closure that returns the content of the notification.
    ///
    /// - Note: Requires a ``View/notificationRoot(:_)`` been installed higher up the view hierarchy.
    ///
    @ViewBuilder func cover<Content: View>(
        isPresented: Binding<Bool>,
        background: NotificationBackground = .none,
        content: @escaping () -> Content
    ) -> some View {
        #if DISABLE_POPUPKIT_IN_PREVIEWS
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            self
        } else {
            modifier(
                CoverModifier(
                    isPresented: isPresented,
                    background: .ultraThinMaterial,
                    content: content
                )
            )
        }
        #else
        modifier(
            CoverModifier(
                isPresented: isPresented,
                background: .ultraThinMaterial,
                content: content
            )
        )
        #endif
    }
}

struct CoverModifier<T: View, S: ShapeStyle>: ViewModifier {
    @EnvironmentObject private var presenter: CoverPresenter
    @State private var coverId = UUID()
    
    @Binding var isPresented: Bool
//    let expiration: ExpirationPolicy
//    let background: NotificationBackground  // TODO: rename?
    let backround: S
    let foreground: () -> T
    
    init(
        isPresented: Binding<Bool>,
        background: S = .ultraThinMaterial,
        content: @escaping () -> T
    ) {
        self._isPresented = isPresented
        self.background = background
        self.foreground = content
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { presented in
                if presented {
                    dprint(presenter.isVerbose, "notification [\(coverId)]: present me 🤲")
                    var presentedId: UUID?
                    withAnimation(presenter.insertionAnimation) {
                        presentedId = presenter.present(
                            id: coverId,
//                            expiration: expiration,
                            content: {
                                foreground()
//                                    .modifier(DefaultNotificationBackground(variant: background))
                            }
                        )
                    }
                    if presentedId == nil { isPresented = false }
                } else {
                    if presenter.isStacked(coverId) {
                        dprint(presenter.isVerbose, "notification [\(coverId)]: dismiss me 🫠")
                        presenter.dismiss(coverId)
                    }
                }
            }
            .onChange(of: presenter.stack) { stack in
                if stack.find(coverId) == nil {
                    withAnimation(presenter.removalAnimation) { isPresented = false }
                }
            }
    }
}
