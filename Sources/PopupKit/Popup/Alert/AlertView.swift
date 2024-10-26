//
//  AlertView.swift
//  PopupKit
//
//  Created by Илья Аникин on 18.10.2024.
//

import SwiftUI

struct AlertView<Content: View>: View {
    let content: () -> Content
    let actions: () -> [Action]

    @State private var size: CGSize = .zero
    @State private var feedback = UIImpactFeedbackGenerator(style: .rigid)

    @EnvironmentObject var presenter: PopupPresenter

    init(content: @escaping () -> Content, actions: @escaping () -> [Action]) {
        self.content = content
        self.actions = actions
    }

    var body: some View {
        VStack(spacing: 0) {
            content()
                .sizeReader(size: $size)

            ActionsView(
                contentSize: size,
                actions: actions,
                dismiss: {
                    presenter.popLast()
                    feedback.impactOccurred(intensity: 0.5)
                }
            )
        }
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20.0))
        .frame(width: 300)
        .padding(.horizontal, 50)
        .padding(.top, 20)
    }
}

extension AlertView where Content == _DefaultAlertViewHeader {
    init(title: String?, msg: String?, actions: @escaping () -> [Action]) {
        self.init(
            content: { _DefaultAlertViewHeader(title: title, msg: msg) },
            actions: actions
        )
    }
}

/// Provides a way to achieve a default generic argument within a View.
struct _DefaultAlertViewHeader: View {
    let title: String?
    let msg: String?

    public var body: some View {
        VStack {
            if let title {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
            }

            if let msg {
                Text(msg).font(.subheadline)
            }
        }
        .multilineTextAlignment(.center)
        .padding(20)
    }
}

#Preview {
    AlertView(
        title: "Title",
        msg: "This is a test message"
    ) {
        [
            Regular(
                text: Text("Action with icon"),
                image: .systemName("sparkles"),
                action: {}
            ),
            Destructive(
                text: Text("Destructive action"),
                action: {}
            ),
            Regular(
                text: Text("Action with icon"),
                image: .systemName("sparkles"),
                action: {}
            ),
            Destructive(
                text: Text("Destructive action"),
                action: {}
            ),
            Cancel(text: Text("My cancel 1")),
            Cancel(text: Text("My cancel 2")),
            Regular(
                text: Text("Thin small-sized text action")
                    .font(.system(size: 10, weight: .thin))
                    .foregroundColor(.black),
                action: {}
            ),
            Regular(
                text: Text("Big bold colored text action")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.indigo),
                action: {}
            )
        ]
    }
    .preferredColorScheme(.dark)
    .previewPopupKit(.popup(ignoredSafeAreaEdges: []))
    .environment(\.popupActionTint, .mint)
}
