//
//  FullscreenRootModifier.swift
//  PopupKit
//
//  Created by Илья Аникин on 17.10.2024.
//

import SwiftUI

public extension View {
    func popupRoot(_ transition: AnyTransition = .popup) -> some View {
        modifier(PopupRootModifier(transition: transition))
            .ignoresSafeArea(.container, edges: .all)
    }
}

struct PopupRootModifier: ViewModifier {
    @EnvironmentObject private var presenter: PopupPresenter

    @State private var safeAreaInsets: EdgeInsets = Self.fetchInsets()
    @State private var isKeyboardPresent: Bool = false

    let transition: AnyTransition
    
    init(transition: AnyTransition) {
        self.transition = transition
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                if !presenter.stack.isEmpty {
                    ZStack {
                        if !presenter.stack.isEmpty {
                            Color.black.opacity(0.3)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    switch presenter.stack.last?.outTapBehavior {
                                    case .dismiss:
                                        presenter.popLast()
                                    default:
                                        break
                                    }
                                }
                        }

                        ForEach(presenter.stack) { entry in
                            entry.view
                                .padding(safeAreaInsets.resolvingInSet(entry.ignoresEdges))
                                .blur(radius: calcBlur(deep: entry.deep, total: presenter.stack.count))
                                .scaleEffect(calcScale(deep: entry.deep, total: presenter.stack.count))
                                .zIndex(Double(entry.deep))
                                .transition(transition)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onReceive(
                        NotificationCenter.default
                            .publisher(for: UIDevice.orientationDidChangeNotification)
                            .delay(for: .milliseconds(1), scheduler: RunLoop.main)
                            .map { _ in Self.fetchInsets() }
                            .removeDuplicates()
                    ) { newInsets in
                        safeAreaInsets = newInsets
                    }
                    .onKeyboardAppear { appeared in
                        if !presenter.stack.isEmpty {
                            withAnimation(.spring) { isKeyboardPresent = appeared }
                        }
                    }
                    .transition(transition)
                }
            }
            .statusBarHidden(!presenter.stack.isEmpty)
    }
    
    private func calcBlur(deep: Int, total: Int) -> CGFloat {
        Double(total) - Double(deep) - 1.0
    }
    
    private func calcScale(deep: Int, total: Int) -> CGSize {
        let scale: Double = 1.0 - 0.05 * (Double(total) - (Double(deep) + 1.0))
        
        return CGSize(width: scale, height: scale)
    }
    
    private static func fetchInsets() -> EdgeInsets {
        UIApplication.shared.keyWindow?.safeAreaInsets.toSwiftUIInsets ?? EdgeInsets()
    }
}
