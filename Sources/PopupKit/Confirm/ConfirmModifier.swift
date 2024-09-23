//
//  ConfirmModifier.swift
//  PopupKit
//
//  Created by Илья Аникин on 23.09.2024.
//

import SwiftUI

public extension View {
    /// Presents a confirmation dialog with **PopupKit**.
    ///
    /// Confirmation dialog  is similar to system confirmation dialog. Cover is screen-wide view with configurable height, attached to top or bottom edge of the screen.
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
    @ViewBuilder func confirm<Content: View, S: ShapeStyle>(
        isPresented: Binding<Bool>,
        background: S = .ultraThinMaterial,
        cornerRadius: Double = 20.0,
        header: @escaping () -> Content,
        actions: @escaping () -> [ConfirmPresenter.Action]
    ) -> some View {
        #if DISABLE_POPUPKIT_IN_PREVIEWS
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            self
        } else {
            modifier(
                ConfirmModifier(
                    isPresented: isPresented,
                    background: background,
                    cornerRadius: cornerRadius,
                    content: header,
                    actions: actions
                )
            )
        }
        #else
        modifier(
            ConfirmModifier(
                isPresented: isPresented,
                background: background,
                cornerRadius: cornerRadius,
                content: header,
                actions: actions
            )
        )
        #endif
    }
    
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
    ///    - item: An `Identifiable?` value that determines whether
    ///  to present the view that you create in the modifier's `content` closure.
    ///    - background: Background style of the presentable view.
    ///    - modal: Modality of the presentable view.
    ///    - cornerRadius: Radius of all cornrers of the presentable view.
    ///    - content: A closure that returns the content of the notification.
    ///
    /// - Note: Requires a ``View/coverRoot(:_)`` been called higher up the view hierarchy.
    ///
    func confirm<Content: View, S: ShapeStyle, Item: Identifiable>(
        item: Binding<Item?>,
        background: S = .ultraThinMaterial,
        cornerRadius: Double = 20.0,
        header: @escaping () -> Content,
        actions: @escaping () -> [ConfirmPresenter.Action]
    ) -> some View {
        confirm(
            isPresented: Binding(
                get: { item.wrappedValue != nil },
                set: { if !$0 { item.wrappedValue = nil } }
            ),
            background: background,
            cornerRadius: cornerRadius,
            header: header,
            actions: actions
        )
    }
}

struct ConfirmModifier<V: View, S: ShapeStyle>: ViewModifier {
    @EnvironmentObject private var presenter: ConfirmPresenter
    @State private var coverId = UUID()
    
    @Binding var isPresented: Bool
    let background: S
    let cornerRadius: Double
    let header: () -> V
    let actions: () -> [ConfirmPresenter.Action]

    init(
        isPresented: Binding<Bool>,
        background: S,
        cornerRadius: Double,
        content: @escaping () -> V,
        actions: @escaping () -> [ConfirmPresenter.Action]
    ) {
        self._isPresented = isPresented
        self.background = background
        self.cornerRadius = cornerRadius
        self.header = content
        self.actions = actions
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { presented in
                if presented {
                    dprint(presenter.isVerbose, "confirmation dialog: present me 🤲")
                    var successed: Bool = false
                    withAnimation(presenter.insertionAnimation) {
                        successed = presenter.present(
                            background: background,
                            cornerRadius: cornerRadius,
                            content: header,
                            actions: actions
                        )
                    }
                    isPresented = successed
                } else {
                    if presenter.isPresented() {
                        dprint(presenter.isVerbose, "confirmation dialog: dismiss me 🫠")
                        presenter.dismiss()
                    }
                }
            }
            .onChange(of: presenter.presented) { stack in
                guard presenter.presented == nil else { return }
                withAnimation(presenter.removalAnimation) { isPresented = false }
            }
    }
}
