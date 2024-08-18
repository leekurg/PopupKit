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
        transition: AnyTransition = .notification
    ) -> some View {
        modifier(
            NotificationRootModifier(
                alignment: alignment,
                transition: transition
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

    private let maxNotificationWidth = 500.0
    private let minNotificationHeight = 100.0
    private let dragThreshold = 300.0
    
    init(alignment: Alignment, transition: AnyTransition) {
        self.alignment = alignment
        self.transition = transition
        self.dismissDirection = .init(alignment: alignment)
        
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
                            .frame(maxWidth: maxNotificationWidth, minHeight: minNotificationHeight)
                            .background {
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(.thinMaterial)
                                    .overlay {
                                        ContainerRelativeShape()
                                            .stroke(.blue, lineWidth: 0.5)
                                            .padding(5)
                                    }
                            }
                            .containerShape(RoundedRectangle(cornerRadius: 30))
                            .padding()
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
                    if !topEntryDraggedAway { state = value.translation.height }
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
