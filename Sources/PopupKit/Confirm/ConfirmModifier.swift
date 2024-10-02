//
//  ConfirmModifier.swift
//  PopupKit
//
//  Created by Илья Аникин on 23.09.2024.
//

import SwiftUI

public extension View {
    /// Presents a confirmation dialog using **PopupKit**.
    ///
    /// This confirmation dialog mimics the system confirmation dialog. It can have an optional header ``View``
    /// and a collection of specified actions.
    /// The dialog is presented above all other views, which are dimmed out in the background.
    /// A tap on any action or unoccupied space will dismiss the dialog.
    ///
    /// Actions are displayed as buttons, optionally containing ``Text`` and/or ``Image``.
    /// Each action has a designated role defined by ``ConfirmPresenter/Action/Role``,
    /// and its presentation style is determined accordingly.
    ///
    /// To create a confirmation dialog, provide an optional `View` for the dialog header and a collection of actions.
    ///
    /// - Parameters:
    ///   - isPresented: A binding to a Boolean value that determines whether the dialog is presented.
    ///   - header: A closure that returns the content of the header view for the dialog.
    ///   - actions: A closure used to build a collection of actions for the dialog.
    ///     Actions are presented in the order they are provided, with **.cancel** actions
    ///     always placed at the bottom of the dialog (in their original order).
    ///     If no cancel actions are provided, a default, **non-localized** cancel action will be displayed.
    ///
    /// - Note: Requires a ``View/confirmRoot(:_)`` been called higher up the view hierarchy.
    /// - Note: Only one confirmation dialog can be displayed at a time.
    ///   Any attempts to present another dialog while one is already being displayed will be ignored.
    ///
    @ViewBuilder func confirm<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder header: @escaping () -> Content = { EmptyView() },
        actions: @escaping () -> [ConfirmPresenter.Action]
    ) -> some View {
        #if DISABLE_POPUPKIT_IN_PREVIEWS
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            self
        } else {
            modifier(
                ConfirmModifier(
                    isPresented: isPresented,
                    header: header,
                    actions: actions
                )
            )
        }
        #else
        modifier(
            ConfirmModifier(
                isPresented: isPresented,
                header: header,
                actions: actions
            )
        )
        #endif
    }

    /// Presents a confirmation dialog using **PopupKit**.
    ///
    /// This confirmation dialog mimics the system confirmation dialog. It can have an optional header ``View``
    /// and a collection of specified actions.
    /// The dialog is presented above all other views, which are dimmed out in the background.
    /// A tap on any action or unoccupied space will dismiss the dialog.
    ///
    /// Actions are displayed as buttons, optionally containing ``Text`` and/or ``Image``.
    /// Each action has a designated role defined by ``ConfirmPresenter/Action/Role``,
    /// and its presentation style is determined accordingly.
    ///
    /// To create a confirmation dialog, provide an optional `View` for the dialog header and a collection of actions.
    ///
    /// - Parameters:
    ///   - item: An `Identifiable?` value that determines whether the dialog is presented.
    ///   - header: A closure that returns the content of the header view for the dialog.
    ///   - actions: A closure used to build a collection of actions for the dialog.
    ///     Actions are presented in the order they are provided, with **.cancel** actions
    ///     always placed at the bottom of the dialog (in their original order).
    ///     If no cancel actions are provided, a default, **non-localized** cancel action will be displayed.
    ///
    /// - Note: Requires a ``View/confirmRoot(:_)`` been called higher up the view hierarchy.
    /// - Note: Only one confirmation dialog can be displayed at a time.
    ///   Any attempts to present another dialog while one is already being displayed will be ignored.
    ///
    func confirm<Content: View, Item: Identifiable>(
        item: Binding<Item?>,
        @ViewBuilder header: @escaping () -> Content = { EmptyView() },
        actions: @escaping () -> [ConfirmPresenter.Action]
    ) -> some View {
        confirm(
            isPresented: Binding(
                get: { item.wrappedValue != nil },
                set: { if !$0 { item.wrappedValue = nil } }
            ),
            header: header,
            actions: actions
        )
    }
}

struct ConfirmModifier<V: View>: ViewModifier {
    @EnvironmentObject private var presenter: ConfirmPresenter
    @Environment(\.confirmTint) var tintColor
    @Environment(\.confirmFonts) var fonts

    @State private var coverId = UUID()
    
    @Binding var isPresented: Bool
    let header: () -> V
    let actions: () -> [ConfirmPresenter.Action]

    init(
        isPresented: Binding<Bool>,
        header: @escaping () -> V,
        actions: @escaping () -> [ConfirmPresenter.Action]
    ) {
        self._isPresented = isPresented
        self.header = header
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
                            tint: tintColor,
                            fonts: fonts,
                            header: header,
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
