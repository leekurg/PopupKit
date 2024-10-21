//
//  DefaultPopupView.swift
//  PopupKit
//
//  Created by Илья Аникин on 18.10.2024.
//

import SwiftUI

let dividerHeight = 1.0 / 3.0

public struct DefaultPopupView<Content: View>: View {
    let content: () -> Content
    let actions: () -> [Action]

    @State private var size: CGSize = .zero
    @State private var feedback = UIImpactFeedbackGenerator(style: .rigid)
    
    @EnvironmentObject var presenter: PopupPresenter
    
    public init(content: @escaping () -> Content, actions: @escaping () -> [Action]) {
        self.content = content
        self.actions = actions
    }
    
    public var body: some View {
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
        .onChange(of: size) { value in
            print("size: \(size)")
        }
    }
}

public extension DefaultPopupView where Content == _DefaultPopupViewHeader {
    init(title: String, msg: String, actions: @escaping () -> [Action]) {
        self.init(
            content: { _DefaultPopupViewHeader(title: title, msg: msg) },
            actions: actions
        )
    }
}

/// Internal type.
///
/// Provides a way to achieve a default generic argument within a View.
public struct _DefaultPopupViewHeader: View {
    let title: String
    let msg: String

    public var body: some View {
        VStack {
            Text(title)
                .font(.headline)
            
            Text(msg)
                .font(.subheadline)
        }
        .padding(.vertical, 20)
    }
}

struct ActionsView: View {
    let contentSize: CGSize
    let actions: () -> [Action]
    let dismiss: () -> Void
    
    @Environment(\.popupActionFonts) var fonts
    @Environment(\.popupActionTint) var tint

    @State private var safeAreaInsets: EdgeInsets = Self.fetchInsets()
    @State private var _actions: SegregatedActions = .empty
    @State private var layout: ActionsLayout = .vertical
    @State private var scrollHeight: CGFloat = .zero
    @State private var scrollAxis: Axis.Set = []

    var body: some View {
        Group {
            switch layout {
            case .vertical:
                ScrollView(scrollAxis) {
                    VStack(spacing: 0) {
                        ForEach(_actions.regular) { action in
                            if !_actions.regular.isEmpty { Divider() }

                            makeActionView(action, tint: tint, dismiss: dismiss)
                                .font(fonts.regular)
                        }

                        ForEach(_actions.cancel) { action in
                            if !_actions.cancel.isEmpty { Divider() }

                            makeActionView(action, tint: tint, dismiss: dismiss)
                                .font(fonts.cancel)
                        }
                    }
                }
                .frame(height: scrollHeight)
            case .horizontal:
                if let regular = _actions.regular.first, let cancel = _actions.cancel.first {
                    Divider()

                    HStack(spacing: 0) {
                        makeActionView(regular, tint: tint, dismiss: dismiss)
                            .font(fonts.regular)

                        Divider().frame(height: ActionContext.alert.height)

                        makeActionView(cancel, tint: tint, dismiss: dismiss)
                            .font(fonts.cancel)
                    }
                }
            }
        }
        .onReceive(
            NotificationCenter.default
                .publisher(for: UIDevice.orientationDidChangeNotification)
                .delay(for: .milliseconds(1), scheduler: RunLoop.main)
                .map { _ in Self.fetchInsets() }
                .removeDuplicates()
        ) { newInsets in
            print("safeArea update: \(newInsets)")
            safeAreaInsets = newInsets

            resolveScrollable(
                contentSize: contentSize,
                actionsCount: _actions.count,
                layout: layout,
                safeAreaInsets: newInsets
            )
        }
        .task {
            let segregated = actions().segregate()
            _actions = .init(regular: segregated.regular, cancel: segregated.cancel)

            layout = _actions.count != 2 ? .vertical : .horizontal
        }
        .onChange(of: _actions.count) { count in
            resolveScrollable(
                contentSize: contentSize,
                actionsCount: count,
                layout: layout,
                safeAreaInsets: safeAreaInsets
            )
        }
        .onChange(of: contentSize) { newSize in
            resolveScrollable(
                contentSize: contentSize,
                actionsCount: _actions.count,
                layout: layout,
                safeAreaInsets: safeAreaInsets
            )
        }
    }

    private func resolveScrollable(contentSize: CGSize, actionsCount: Int, layout: ActionsLayout, safeAreaInsets: EdgeInsets) {
        // estimated
        let estimatedActionH = switch layout {
        case .vertical:
            CGFloat(actionsCount) * (ActionContext.alert.height + dividerHeight)
        case .horizontal:
            (ActionContext.alert.height + dividerHeight)
        }

        let safeAreaInsets = Self.fetchInsets()
        let edgePadding = max(safeAreaInsets.top, safeAreaInsets.bottom)
        let proposedHeight = UIScreen.main.bounds.height - 2 * edgePadding
        print("proposed height: \(proposedHeight) (\(UIScreen.main.bounds.height) - 2 * \(edgePadding))")

        scrollAxis = (contentSize.height + estimatedActionH) > proposedHeight
            ? .vertical
            : []

        scrollHeight = max(min(estimatedActionH, proposedHeight - contentSize.height), 1)
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
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.alert(context: .alert))
    }

    private static func fetchInsets() -> EdgeInsets {
        UIApplication.shared.keyWindow?.safeAreaInsets.toSwiftUIInsets ?? EdgeInsets()
    }
}

private extension ActionsView {
    enum ActionsLayout {
        case vertical
        case horizontal
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
