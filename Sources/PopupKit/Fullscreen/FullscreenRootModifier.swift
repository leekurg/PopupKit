//
//  FullscreenRootModifier.swift
//
//
//  Created by Илья Аникин on 23.08.2024.
//

import SwiftUI

public extension View {
    func fullscreenRoot(_ transition: AnyTransition = .popup) -> some View {
        modifier(FullscreenRootModifier(transition: transition))
            .ignoresSafeArea(.container, edges: .all)
    }
}

struct FullscreenRootModifier: ViewModifier {
    @EnvironmentObject private var presenter: FullscreenPresenter

    @GestureState private var dragHeight: CGFloat
    @State private var topEntryDraggedAway = false
    @State private var safeAreaInsets: EdgeInsets = Self.fetchInsets()
    @State private var isKeyboardPresent: Bool = false

    let transition: AnyTransition
    let dismissDirection: DismissDirection = .topToBottom
    
    init(transition: AnyTransition) {
        self.transition = transition
        
        self._dragHeight = GestureState(
            initialValue: .zero,
            resetTransaction: .init(animation: .bouncy)
        )
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                if !presenter.stack.isEmpty {
                    ZStack {
                        ForEach(presenter.stack) { entry in
                            ZStack {
                                Rectangle()
                                    .fill(entry.background)
                                
                                entry.view
                                    .padding(safeAreaInsets.resolvingInSet(entry.ignoresEdges))
                                    .padding(.bottom, isKeyboardPresent ? 0 : safeAreaInsets.bottom)
                            }
                            .cornerRadius(safeAreaInsets.bottom, corners: [.topLeft, .topRight])
                            .offset(presenter.isTop(entry.id) ? calcOffset(dragHeight) : .zero)
                            .gesture(if: entry.dismissalScroll.predictedThreshold > 0) {
                                makeDragGesture(threshold: entry.dismissalScroll.predictedThreshold)
                            }
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

    private func makeDragGesture(threshold: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 1)
            .updating($dragHeight) { value, state, _ in
                withAnimation(.spring) {
                    state = topEntryDraggedAway ? 0.0 : value.translation.height
                }
            }
            .onChanged { gesture in
                if
                    !topEntryDraggedAway,
                    dismissDirection.isForward(gesture.predictedEndTranslation.height) == true,
                    abs(gesture.predictedEndTranslation.height) > threshold
                {
                    topEntryDraggedAway = true
                    presenter.popLast()
                }
            }
            .onEnded { _ in topEntryDraggedAway = false }
    }
    
    private func calcOffset(_ dragHeight: CGFloat) -> CGSize {
        return if dismissDirection.isForward(dragHeight) == true {
            CGSize(width: 0, height: dragHeight)
        } else {
            .zero
        }
    }
    
    private static func fetchInsets() -> EdgeInsets {
        UIApplication.shared.keyWindow?.safeAreaInsets.toSwiftUIInsets ?? EdgeInsets()
    }
}

fileprivate extension View {
    @ViewBuilder func gesture<G: Gesture>(
        if condition: Bool,
        gestureMask: GestureMask = .all,
        gesture: () -> G
    ) -> some View {
        if condition {
            self.gesture(gesture(), including: gestureMask)
        } else {
            self
        }
    }
}
