//
//  FullscreenRootModifier.swift
//
//
//  Created by Илья Аникин on 23.08.2024.
//

import SwiftUI

public extension View {
    func fullscreenRoot(_ transition: AnyTransition = .fullscreen) -> some View {
        modifier(FullscreenRootModifier(transition: transition))
            .ignoresSafeArea(.all)
    }
}

struct FullscreenRootModifier: ViewModifier {
    @EnvironmentObject private var presenter: FullscreenPresenter

    @GestureState private var dragHeight: CGFloat
    @State private var topEntryDraggedAway = false
    @State private var safeAreaInsets: EdgeInsets = Self.initInsets()
    
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
                            }
                            .clipShape(RoundedRectangle(cornerRadius: safeAreaInsets.bottom))
                            .offset(presenter.isTop(entry.id) ? calcOffset(dragHeight) : .zero)
                            .gesture(if: entry.dismissalScroll.predictedThreshold > 0) {
                                makeDragGesture(threshold: entry.dismissalScroll.predictedThreshold)
                            }
                            .zIndex(Double(entry.deep))
                            .transition(transition)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onReceive(NotificationCenter.default.publisher(for: .popupKitSafeAreaChangedNotification)) { msg in
                        if let newInsets = msg.object as? EdgeInsets {
                            safeAreaInsets = newInsets
                        }
                    }
                    .transition(transition)
                }
            }
            .statusBarHidden(!presenter.stack.isEmpty)
    }

    private func makeDragGesture(threshold: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($dragHeight) { value, state, _ in
                withAnimation(.spring) {
                    state = topEntryDraggedAway ? 0.0 : value.translation.height
                }
            }
            .onChanged { gesture in
                if
                    !topEntryDraggedAway,
                    abs(gesture.predictedEndTranslation.height) > threshold,
                    dismissDirection.isForward(gesture.predictedEndTranslation.height) == true
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
    
    private static func initInsets() -> EdgeInsets {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            UIApplication.shared.keyWindow?.safeAreaInsets.toSwiftUIInsets ?? EdgeInsets()
        } else {
            UIApplication.shared.popupKitWindow?.safeAreaInsets.toSwiftUIInsets ?? EdgeInsets()
        }
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

fileprivate extension EdgeInsets {
    func resolvingInSet(_ ignoresEdges: Edge.Set) -> Self {
        EdgeInsets(
            top: ignoresEdges.contains(.top) ? 0 : self.top,
            leading: ignoresEdges.contains(.leading) ? 0 : self.leading,
            bottom: ignoresEdges.contains(.bottom) ? 0 : self.bottom,
            trailing: ignoresEdges.contains(.trailing) ? 0 : self.trailing
        )
    }
}
