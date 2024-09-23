//
//  ConfirmRootModifier.swift
//  PopupKit
//
//  Created by Илья Аникин on 23.09.2024.
//

import SwiftUI

public extension View {
    func confirmRoot<S: ShapeStyle>(
        transition: AnyTransition = .move(edge: .bottom),
        background: S = .ultraThinMaterial,
        cornerRadius: Double = 20.0,
        dragThreshold: CGFloat = 200.0
    ) -> some View {
        modifier(
            ConfirmRootModifier(
                transition: transition,
                background: background,
                cornerRadius: cornerRadius,
                dragThreshold: dragThreshold
            )
        )
        .ignoresSafeArea(.all)
    }
}

struct ConfirmRootModifier<S: ShapeStyle>: ViewModifier {
    @EnvironmentObject private var presenter: ConfirmPresenter
    @GestureState private var dragHeight: CGFloat
    @State private var safeAreaInsets: EdgeInsets = Self.initInsets()
    
    private let transition: AnyTransition
    private let background: S
    private let cornerRadius: Double

    private let alignment: Alignment = .bottom
    private let dismissDirection: DismissDirection = .topToBottom
    private let dragThreshold: CGFloat
    
    init(
        transition: AnyTransition,
        background: S,
        cornerRadius: Double,
        dragThreshold: CGFloat
    ) {
        self.transition = transition
        self.background = background
        self.cornerRadius = cornerRadius
        self.dragThreshold = dragThreshold
        
        self._dragHeight = GestureState(
            initialValue: .zero,
            resetTransaction: .init(animation: .bouncy)
        )
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment.opposite) {
                ZStack(alignment: alignment) {
                    if let entry = presenter.presented {
                        Color.black.opacity(0.3)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                presenter.dismiss()
                            }
                            .zIndex(1)
                    
                        VStack(spacing: 20) {
                            VStack(spacing: 0) {
                                entry.view.padding()
                                
                                ForEach(entry.actions) { action in
                                    VStack(spacing: 0) {
                                        if entry.actions.count > 0 {
                                            Divider()
                                        }
                                        
                                        makeActionView(action)
                                    }
                                    .background(.clear, in: Rectangle())
                                }
                            }
                            .background(background, in: RoundedRectangle(cornerRadius: cornerRadius))
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                            
                            VStack(spacing: 0) {
                                ForEach(entry.cancelActions) { action in
                                    VStack(spacing: 0) {
                                        if entry.cancelActions.count > 1 {
                                            Divider()
                                        }
                                        
                                        makeActionView(action)
                                    }
                                }
                                .background(.clear, in: Rectangle())
                            }
                            .background(background, in: RoundedRectangle(cornerRadius: cornerRadius))
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, safeAreaInsets.bottom)
                        .offset(calcOffset(dragHeight: dragHeight))
                        .scaleEffect(calcScale(dragHeight: dragHeight), anchor: alignment.toUnitPoint())
                        .gesture(makeDragGesture())
                        .transition(transition)
                        .zIndex(2)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
                .clipped()
            }
            .onReceive(NotificationCenter.default.publisher(for: .popupKitSafeAreaChangedNotification)) { msg in
                if let newInsets = msg.object as? EdgeInsets {
                    safeAreaInsets = newInsets
                }
            }
    }
    
    private func makeActionView(_ action: ConfirmPresenter.Action) -> some View {
        Button {
            action.action()
            presenter.dismiss()
        } label: {
            HStack {
                if let image = action.image?.buildImage() {
                    image
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(height: 20)
                }
                
                if let text = action.text {
                    if action.kind == .destructive {
                        text.foregroundStyle(.red)
                    } else {
                        text
                    }
                }
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.confirm(scale: 0.95))
    }
    
    private func makeDragGesture() -> some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($dragHeight) { value, state, _ in
                withAnimation(.spring) {
                    state = value.translation.height
                }
            }
            .onChanged { gesture in
                if
                    abs(gesture.predictedEndTranslation.height) > dragThreshold,
                    dismissDirection.isForward(gesture.predictedEndTranslation.height) == true
                {
                    presenter.dismiss()
                }
            }
    }

    private func calcOffset(dragHeight: CGFloat) -> CGSize {
        let modulatedDragHeight: CGFloat
        if dismissDirection.isForward(dragHeight) == true {
            modulatedDragHeight = dragHeight
        } else {
            modulatedDragHeight = .zero
        }
        
        let offset = -modulatedDragHeight * dismissDirection.sign
        
        return switch dismissDirection {
        case .topToBottom: CGSize(width: 0, height: -offset)
        case .bottomToTop: CGSize(width: 0, height: offset)
        case .unknown: .zero
        }
    }
    
    private func calcScale(
        dragHeight: CGFloat
    ) -> CGSize {
        let scaleY: Double = switch dismissDirection.isForward(dragHeight) {
        case .some(true):
            1.0
        case .some(false):
            1.0 - dismissDirection.sign * dragHeight / 10000.0
        case .none: 1.0
        }
        
        return CGSize(width: 1.0, height: scaleY)
    }
    
    private static func initInsets() -> EdgeInsets {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            UIApplication.shared.keyWindow?.safeAreaInsets.toSwiftUIInsets ?? EdgeInsets()
        } else {
            UIApplication.shared.popupKitWindow?.safeAreaInsets.toSwiftUIInsets ?? EdgeInsets()
        }
    }
}
