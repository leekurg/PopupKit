//
//  ActionsView.swift
//  PopupKit
//
//  Created by Илья Аникин on 22.10.2024.
//

import Combine
import SwiftUI

struct ActionsView: View {
    let contentSize: CGSize
    let actions: () -> [Action]
    let dismiss: () -> Void

    @Environment(\.popupActionFonts) var fonts
    @Environment(\.popupActionTint) var tint

    @StateObject private var vm = ActionsViewModel()

    var body: some View {
        Group {
            switch vm.layout {
            case .vertical:
                ScrollView(vm.scrollAxis) {
                    VStack(spacing: 0) {
                        ForEach(vm.actions.regular) { action in
                            if !vm.actions.regular.isEmpty { Divider() }

                            makeActionView(action, tint: tint, dismiss: dismiss)
                                .font(fonts.regular)
                        }

                        ForEach(vm.actions.cancel) { action in
                            if !vm.actions.cancel.isEmpty { Divider() }

                            makeActionView(action, tint: tint, dismiss: dismiss)
                                .font(fonts.cancel)
                        }
                    }
                }
                .frame(height: vm.scrollHeight)
            case .horizontal:
                if let regular = vm.actions.regular.first, let cancel = vm.actions.cancel.first {
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
        .onAppear {
            vm.set(actions: actions, contentHeight: contentSize.height)
        }
        .onChange(of: contentSize) { newSize in
            print("🔄 content size changed")
            vm.set(contentHeight: newSize.height)
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
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.alert(context: .alert))
    }
}

final class ActionsViewModel: ObservableObject {
    @Published var actions: SegregatedActions = .empty
    @Published var layout: Layout = .vertical
    @Published var scrollAxis: Axis.Set = []
    @Published var scrollHeight: CGFloat = .zero

    private let dividerHeight = 1.0 / 3.0
    private var contentHeight: CGFloat = .zero
    private var cancellables: Set<AnyCancellable> = []

    init() {
        NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .map { _ in UIDevice.current.orientation }
            .filter { orientation in
                switch orientation {
                case .portrait, .landscapeLeft, .landscapeRight: true
                default: false
                }
            }
            .removeDuplicates()
            // Delayed to allow clients fetch new orientation value directly from UIDevice
            .delay(for: .milliseconds(1), scheduler: RunLoop.main)
            .sink { _ in self.update() }
            .store(in: &cancellables)
    }

    func set(actions: (() -> [Action])? = nil, contentHeight: CGFloat? = nil) {
        if let actions = actions {
            self.actions = actions().segregate()
        }

        if let contentHeight {
            self.contentHeight = contentHeight
        }

        update()
    }

    private func update() {
        // estimated
        let estimatedActionH = switch layout {
        case .vertical:
            CGFloat(actions.count) * (ActionContext.alert.height + dividerHeight)
        case .horizontal:
            (ActionContext.alert.height + dividerHeight)
        }

        let safeAreaInsets = fetchInsets()
        let edgePadding = max(safeAreaInsets.top, safeAreaInsets.bottom)
        let proposedHeight = UIScreen.main.bounds.height - 2 * edgePadding

        scrollAxis = (contentHeight + estimatedActionH) > proposedHeight
            ? .vertical
            : []

        scrollHeight = max(min(estimatedActionH, proposedHeight - contentHeight), 1)

        print("💫 proposed height: \(proposedHeight) (\(UIScreen.main.bounds.height) - 2 * \(edgePadding))")
        print("   content h - \(String(format: "%.1f", contentHeight))")
        print("   scroll: axis - \(scrollAxis),  h - \(String(format: "%.1f", scrollHeight))")
    }

    private func fetchInsets() -> EdgeInsets {
        UIApplication.shared.keyWindow?.safeAreaInsets.toSwiftUIInsets ?? EdgeInsets()
    }
}

extension ActionsViewModel {
    enum Layout {
        case vertical
        case horizontal
    }
}
