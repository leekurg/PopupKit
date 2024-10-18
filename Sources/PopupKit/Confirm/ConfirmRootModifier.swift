//
//  ConfirmRootModifier.swift
//  PopupKit
//
//  Created by Илья Аникин on 23.09.2024.
//

import SwiftUI

public extension View {
    /// Sets the *root view* for **PopupKit**'s confirmation dialog presentations.
    ///
    /// ## Overview
    /// The *root view* defines the location within the view hierarchy from which confirmation dialogs will be presented.
    /// Any confirmation dialogs invoked from lower in the hierarchy will be displayed from this root view.
    /// You can configure various customization options for the dialog’s appearance and behavior.
    ///
    /// - Parameters:
    ///   - transition: Specifies the transition animation for adding or removing a confirmation dialog from the view hierarchy.
    ///   - background: Defines the background style for the dialog’s header, regular actions, and destructive actions.
    ///   - cancelBackground: Defines the background style specifically for cancel actions.
    ///   - cornerRadius: Sets the corner radius for the dialog’s edges.
    ///   - dragThreshold: Sets the minimum swipe distance required to dismiss the dialog.
    ///
    /// - Note: Use the ``View/confirm(_)`` modifier to present a confirmation dialog.
    ///
    func confirmRoot<S1: ShapeStyle, S2: ShapeStyle>(
        transition: AnyTransition = .move(edge: .bottom),
        background: S1 = .thinMaterial,
        cancelBackground: S2 = .regularMaterial,
        cornerRadius: Double = 15.0,
        dragThreshold: CGFloat = 200.0
    ) -> some View {
        modifier(
            ConfirmRootModifier(
                transition: transition,
                background: background,
                cancelBackground: cancelBackground,
                cornerRadius: cornerRadius,
                dragThreshold: dragThreshold
            )
        )
        .ignoresSafeArea(.all)
    }
}

struct ConfirmRootModifier<S1: ShapeStyle, S2: ShapeStyle>: ViewModifier {
    @EnvironmentObject private var presenter: ConfirmPresenter
    @GestureState private var dragHeight: CGFloat
    @State private var isDragging = false
    @State private var safeAreaInsets: EdgeInsets = Self.initInsets()

    private let transition: AnyTransition
    private let background: S1
    private let cancelBackground: S2
    private let cornerRadius: Double

    private let alignment: Alignment = .bottom
    private let dismissDirection: DismissDirection = .topToBottom
    private let dragThreshold: CGFloat
    
    init(
        transition: AnyTransition,
        background: S1,
        cancelBackground: S2,
        cornerRadius: Double,
        dragThreshold: CGFloat
    ) {
        self.transition = transition
        self.background = background
        self.cancelBackground = cancelBackground
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

                        VStack(spacing: 10) {
                            VStack(spacing: 0) {
                                entry.view.padding()

                                // Actions
                                ForEach(entry.actions) { action in
                                    VStack(spacing: 0) {
                                        if entry.actions.count > 0 {
                                            Divider()
                                        }
                                        
                                        makeActionView(action, tint: entry.tint)
                                            .font(entry.fonts.regular)
                                    }
                                    .background(.clear, in: Rectangle())
                                }
                            }
                            .background(background, in: RoundedRectangle(cornerRadius: cornerRadius))
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))

                            // Cancel actions
                            VStack(spacing: 0) {
                                ForEach(entry.cancelActions) { action in
                                    VStack(spacing: 0) {
                                        if entry.cancelActions.count > 1 {
                                            Divider()
                                        }
                                        
                                        makeActionView(action, tint: entry.tint)
                                            .font(entry.fonts.cancel)
                                    }
                                }
                                .background(.clear, in: Rectangle())
                            }
                            .background(cancelBackground, in: RoundedRectangle(cornerRadius: cornerRadius))
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, safeAreaInsets.bottom)
                        .offset(calcOffset(dragHeight: isDragging ? dragHeight : 0))
                        .scaleEffect(
                            calcScale(dragHeight: isDragging ? dragHeight : 0),
                            anchor: alignment.toUnitPoint()
                        )
                        .gesture(makeDragGesture())
                        .transition(transition)
                        .id(entry.id)
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

    private func makeActionView(_ action: Action, tint: Color) -> some View {
        Button {
            action.action()
            presenter.dismiss(haptic: true)
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
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.confirm)
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
                isDragging = true
            }
            .onEnded { _ in
                isDragging = false
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
