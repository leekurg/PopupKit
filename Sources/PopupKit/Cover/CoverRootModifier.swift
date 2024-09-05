//
//  CoverRootModifier.swift
//
//
//  Created by Илья Аникин on 25.08.2024.
//

import SwiftUI

public extension View {
    func coverRoot(
        alignment: Alignment = .bottom,
        transition: AnyTransition = .cover,
        dragThreshold: CGFloat = 300.0
    ) -> some View {
        modifier(
            CoverRootModifier(
                alignment: alignment,
                transition: transition,
                dragThreshold: dragThreshold
            )
        )
    }
}

struct CoverRootModifier: ViewModifier {
    @EnvironmentObject private var presenter: CoverPresenter
    @GestureState private var dragHeight: CGFloat
    @State private var topEntryDraggedAway = false
    
    let alignment: Alignment
    let transition: AnyTransition

    private let dismissDirection: DismissDirection
    private let dragThreshold: CGFloat
    
    init(
        alignment: Alignment,
        transition: AnyTransition,
        dragThreshold: CGFloat
    ) {
        self.alignment = alignment
        self.transition = transition
        self.dismissDirection = .init(alignment: alignment)
        
        self.dragThreshold = dragThreshold
        
        self._dragHeight = GestureState(
            initialValue: .zero,
            resetTransaction: .init(animation: .bouncy)
        )
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                ZStack(alignment: alignment) {
                    ForEach(presenter.stack) { entry in
                        VStack {
                            entry.view
                        }
//                        .frame(maxWidth: maxNotificationWidth, minHeight: minNotificationHeight)
                        .zIndex(Double(entry.deep))
                        .cornerRadius(presenter.isTop(entry.id) ? 0 : 16)
                        .offset(
                            calcOffset(
                                deep: entry.deep,
                                stackCount: presenter.stack.count,
                                dragHeight: dragHeight,
                                alignment: alignment
                            )
                        )
                        .scaleEffect(
                            calcScale(
                                deep: entry.deep,
                                stackCount: presenter.stack.count,
                                dragHeight: dragHeight
                            ),
                            anchor: alignment.toUnitPoint()
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
                        .transition(transition)
                    }
                }
                .overlay {
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(makeDragGesture())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
            }
    }
    
    private func makeDragGesture() -> some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($dragHeight) { value, state, _ in
                withAnimation(.spring) {
                    state = topEntryDraggedAway ? 0.0 : value.translation.height
                }
            }
            .onChanged { gesture in
                if
                    !topEntryDraggedAway,
                    abs(gesture.predictedEndTranslation.height) > dragThreshold,
                    dismissDirection.isForward(gesture.predictedEndTranslation.height) == true
                {
                    topEntryDraggedAway = true
                    presenter.popLast()
                }
            }
            .onEnded { _ in topEntryDraggedAway = false }
    }

    private func calcOffset(
        deep: Int,
        stackCount: Int,
        dragHeight: CGFloat,
        alignment: Alignment
    ) -> CGSize {
        let modulatedDragHeight: CGFloat = switch dismissDirection.isForward(dragHeight) {
        case .some(true):
            deep == stackCount - 1 ? dragHeight : 0
        case .some(false), .none:
            .zero
        }
        
        let offset = -modulatedDragHeight * dismissDirection.sign
        
        return switch dismissDirection {
        case .topToBottom: CGSize(width: 0, height: -offset)
        case .bottomToTop: CGSize(width: 0, height: offset)
        case .unknown: .zero
        }
    }
    
    private func calcScale(
        deep: Int,
        stackCount: Int,
        dragHeight: CGFloat
    ) -> CGSize {
        let scaleY: Double

        if deep == stackCount - 1 {
            scaleY = switch dismissDirection.isForward(dragHeight) {
            case .some(true), .none: 1.0
            case .some(false):
                1.0 - dismissDirection.sign * dragHeight / 10000.0
            }
        } else {
            scaleY = 1.0 + 0.05 * (Double(stackCount) - (Double(deep) + 1.0))
        }
        
        return CGSize(width: 1.0, height: scaleY)
    }
}

fileprivate extension Alignment {
    func toUnitPoint() -> UnitPoint {
        switch self {
        case .bottom: .bottom
        case .bottomLeading: .bottomLeading
        case .bottomTrailing: .bottomTrailing
        case .top: .top
        case .topLeading: .topLeading
        case .topTrailing: .topTrailing
        case .leading: .leading
        case .trailing: .trailing
        default: .zero
        }
    }
}