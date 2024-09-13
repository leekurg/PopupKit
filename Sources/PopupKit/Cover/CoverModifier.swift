//
//  CoverModifier.swift
//
//
//  Created by Илья Аникин on 25.08.2024.
//

import SwiftUI

public extension View {
    /// Presents a cover with **PopupKit**.
    ///
    /// Cover is similar to system sheet. Cover is screen-wide view with configurable height, attached to top or bottom edge of the screen.
    /// Anchor screen edge is provided by calling ``View/coverRoot(:_)``.
    ///
    /// To create a cover you provide a view to display and background style.
    /// Also you can adjust a radius of cover's corners and set a modality mode to it.
    /// Modality determines if user is able to interact with views under this cover and with cover itself.
    /// Learn more about modality at ``Modality``
    ///
    /// - Parameters:
    ///    - isPresented: A binding to a Boolean value that determines whether
    ///  to present the view that you create in the modifier's `content` closure.
    ///    - background: Background style of the presentable view.
    ///    - modal: Modality of the presentable view.
    ///    - cornerRadius: Radius of all cornrers of the presentable view.
    ///    - content: A closure that returns the content of the notification.
    ///
    /// - Note: Requires a ``View/coverRoot(:_)`` been called higher up the view hierarchy.
    ///
    @ViewBuilder func cover<Content: View, S: ShapeStyle>(
        isPresented: Binding<Bool>,
        background: S = .background,
        modal: Modality = .modal(interactivity: .interactive),
        cornerRadius: Double = 20.0,
        content: @escaping () -> Content
    ) -> some View {
        #if DISABLE_POPUPKIT_IN_PREVIEWS
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            self
        } else {
            modifier(
                CoverModifier(
                    isPresented: isPresented,
                    background: background,
                    modal: modal,
                    cornerRadius: cornerRadius,
                    content: content
                )
            )
        }
        #else
        modifier(
            CoverModifier(
                isPresented: isPresented,
                background: background,
                modal: modal,
                cornerRadius: cornerRadius,
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
    let background: S
    let modal: Modality
    let cornerRadius: Double
    let foreground: () -> T
    
    init(
        isPresented: Binding<Bool>,
        background: S,
        modal: Modality,
        cornerRadius: Double,
        content: @escaping () -> T
    ) {
        self._isPresented = isPresented
        self.background = background
        self.modal = modal
        self.cornerRadius = cornerRadius
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
                            modal: modal,
                            background: background,
                            cornerRadius: cornerRadius,
                            content: foreground
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
