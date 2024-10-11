//
//  NotificationRootModifier.swift
//  PopupKit
//
//  Created by Илья Аникин on 03.08.2024.
//

import SwiftUI

public extension View {
    func notificationRoot(
        alignment: Alignment = .bottom,
        transition: AnyTransition = .notificationBottom,
        maxNotificationWidth: CGFloat = 500.0,
        minNotificationFrameHeight: CGFloat? = nil,
        dragThreshold: CGFloat = 300.0
    ) -> some View {
        modifier(
            NotificationRootModifier(
                alignment: alignment,
                transition: transition,
                maxNotificationWidth: maxNotificationWidth,
                minNotificationFrameHeight: minNotificationFrameHeight,
                dragThreshold: dragThreshold
            )
        )
    }
}

struct NotificationRootModifier: ViewModifier {
    @EnvironmentObject private var presenter: NotificationPresenter
    @GestureState private var dragHeight: CGFloat
    @State private var topEntryDraggedAway = false
    
    let alignment: Alignment
    let transition: AnyTransition

    private let dismissDirection: DismissDirection
    private let maxNotificationWidth: CGFloat
    private let minNotificationFrameHeight: CGFloat?
    private let dragThreshold: CGFloat
    
    init(
        alignment: Alignment,
        transition: AnyTransition,
        maxNotificationWidth: CGFloat,
        minNotificationFrameHeight: CGFloat?,
        dragThreshold: CGFloat
    ) {
        self.alignment = alignment
        self.transition = transition
        self.dismissDirection = .init(alignment: alignment)
        
        self.maxNotificationWidth = maxNotificationWidth
        self.minNotificationFrameHeight = minNotificationFrameHeight
        self.dragThreshold = dragThreshold
        
        self._dragHeight = GestureState(
            initialValue: .zero,
            resetTransaction: .init(animation: .bouncy)
        )
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                ZStack {
                    ForEach(presenter.stack) { entry in
                        VStack {
                            entry.view
                        }
                        .frame(maxWidth: maxNotificationWidth, minHeight: minNotificationFrameHeight)
                        .zIndex(Double(entry.deep))
                        .offset(
                            calcOffset(
                                deep: entry.deep,
                                stackCount: presenter.stack.count,
                                dragHeight: dragHeight,
                                alignment: alignment
                            )
                        )
                        .scaleEffect(
                            calcScale(deep: entry.deep, total: presenter.stack.count)
                        )
                        .blur(
                            radius: calcBlur(deep: entry.deep, total: presenter.stack.count)
                        )
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
        case .some(false):
            dragHeight / 10.0 * (CGFloat(deep) + 1.0)
        case .none:
            .zero
        }
        
        let offset = CGFloat(deep) * 10.0 - modulatedDragHeight * dismissDirection.sign
        
        return switch dismissDirection {
        case .topToBottom: CGSize(width: 0, height: -offset)
        case .bottomToTop: CGSize(width: 0, height: offset)
        case .unknown: .zero
        }
    }
    
    private func calcScale(deep: Int, total: Int) -> CGSize {
        let scale: Double = 1.0 - 0.05 * (Double(total) - (Double(deep) + 1.0))
        
        return CGSize(width: scale, height: scale)
    }
    
    private func calcBlur(deep: Int, total: Int) -> CGFloat {
        Double(total) - Double(deep) - 1.0
    }
}
