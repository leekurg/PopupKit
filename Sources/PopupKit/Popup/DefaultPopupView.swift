//
//  DefaultPopupView.swift
//  PopupKit
//
//  Created by Илья Аникин on 18.10.2024.
//

import SwiftUI

let actionCornerSize = 20.0

public struct DefaultPopupView: View {
    let title: String
    let msg: String
    let actions: () -> [PopupKit.Action]
    
    @State private var feedback = UIImpactFeedbackGenerator(style: .rigid)
    
    @EnvironmentObject var presenter: PopupPresenter
    
    public init(title: String, msg: String, actions: @escaping () -> [PopupKit.Action]) {
        self.title = title
        self.msg = msg
        self.actions = actions
    }
    
    public var body: some View {
        VStack {
            VStack {
                Text(title)
                    .font(.headline)
                
                Text(msg)
                    .font(.subheadline)
            }
            .padding(.vertical, 20)
            
            ActionsView(
                actions: actions,
                dismiss: {
                    presenter.popLast()
                    feedback.impactOccurred(intensity: 0.5)
                }
            )
        }
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: actionCornerSize))
        .padding(.horizontal)
    }
}

struct ActionsView: View {
    let actions: () -> [PopupKit.Action]
    let dismiss: () -> Void
    
    @Environment(\.popupActionFonts) var fonts
    @Environment(\.popupActionTint) var tint
    
    // TODO: internal
    public init(actions: @escaping () -> [PopupKit.Action], dismiss: @escaping () -> Void) {
        self.actions = actions
        self.dismiss = dismiss
    }
    
    @State private var _actions: SegregatedActions = .empty
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(_actions.regular) { action in
                if !_actions.regular.isEmpty { Divider() }
                
                makeActionView(action, tint: tint, dismiss: dismiss)
                    .font(fonts.cancel)
            }
            
            ForEach(_actions.cancel) { action in
                if !_actions.cancel.isEmpty { Divider() }
                
                makeActionView(action, tint: tint, dismiss: dismiss)
                    .font(fonts.cancel)
            }
        }
        .task {
            let segregated = actions().segregate()
            _actions = .init(regular: segregated.regular, cancel: segregated.cancel)
        }
    }
    
    private func makeActionView(
        _ action: Action,
        tint: Color,
        dismiss: (() -> Void)?
    ) -> some View {
        Button {
            action.action()
            dismiss?()
        } label: {
            HStack {
                if let image = action.image?.buildImage() {
                    let img = image
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(height: 20)

                    if action.role == .destructive {
                        img.foregroundStyle(.red)
                    } else {
                        img.foregroundStyle(tint)
                    }
                }
                
                if let text = action.text {
                    if action.role == .destructive {
                        text.foregroundStyle(.red)
                    } else {
                        text.foregroundStyle(tint)
                    }
                }
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.confirm)
    }
}

#Preview {
    DefaultPopupView(
        title: "Title",
        msg: "This is a test message"
    ) {
        [
//            .action(
//                text: Text("Action"),
//                action: {}
//            ),
            .action(
                text: Text("Action with icon"),
                image: .systemName("sparkles"),
                action: {}
            ),
            .destructive(
                text: Text("Destructive action"),
                action: {}
            ),
            .cancel(text: Text("My cancel 1")),
            .cancel(text: Text("My cancel 2")),
            .action(
                text: Text("Thin small-sized text action")
                    .font(.system(size: 10, weight: .thin))
                    .foregroundColor(.black),
                action: {}
            ),
            .action(
                text: Text("Big bold colored text action")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.indigo),
                action: {}
            )
        ]
    }
    .previewPopupKit(.popup(ignoredSafeAreaEdges: []))
    .environment(\.popupActionTint, .mint)
}
