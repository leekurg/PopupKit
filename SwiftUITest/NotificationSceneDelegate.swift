//
//  NotificationSceneDelegate.swift
//  SwiftUITest
//
//  Created by Илья Аникин on 17.08.2024.
//

import SwiftUI
import UIKit

class NotificationSceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    private var notificationWindow: UIWindow?
    public lazy var notificationPresenter = NotificationPresenter()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let scene = scene as? UIWindowScene {
            print("✅ scene OK")
            let notificationWindow = PassThroughWindow(windowScene: scene)
            let notificationViewController = UIHostingController(
                rootView: NotificationRootView().environment(notificationPresenter)
            )
            notificationViewController.view.backgroundColor = .clear
            notificationWindow.rootViewController = notificationViewController
            notificationWindow.isHidden = false
            self.notificationWindow = notificationWindow
        }
    }
}

final class PassThroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == hitView ? nil : hitView
    }
}

struct NotificationRootView: View {
    @Environment(NotificationPresenter.self) private var presenter
    @Environment(\.notificationTransitionAnimation) var transitionAnimation
//    @State private var orientation = DeviceOrientation()
    @GestureState private var dragHeight: CGFloat
    @State private var topEntryDraggedAway = false
    
    let alignment: Alignment = .bottom
    let transition: AnyTransition = .notification

    private let closeButtonSize = 20.0
    private let closeButtonPadding = 15.0
    private let maxNotificationWidth = 500.0
    private let minNotificationHeight = 100.0
    
    init(/*alignment: Alignment, transition: AnyTransition*/) {
//        self.alignment = alignment
//        self.transition = transition
        
        self._dragHeight = GestureState(
            initialValue: .zero,
            resetTransaction: .init(animation: .bouncy)
        )
    }

    var body: some View {
        ZStack {
            ForEach(presenter.stack) { entry in
                VStack {
                    entry.view
                }
                .frame(maxWidth: maxNotificationWidth, minHeight: minNotificationHeight)
                .background(content: background)
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
        .ignoresSafeArea()
    }
    
    private func background() -> some View {
        RoundedRectangle(cornerRadius: 30)
            .fill(.thinMaterial)
            .overlay {
                ContainerRelativeShape()
                    .stroke(.blue, lineWidth: 0.5)
                    .padding(5)
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
                    gesture.predictedEndTranslation.height > 300
                {
                    topEntryDraggedAway = true
                    withAnimation(transitionAnimation.removal) {
                        presenter.popLast(transitionAnimation.removal)
                    }
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
        let modulatedDragHeight: CGFloat = switch alignment.direction.isOpposite(dragHeight) {
        case .some(true):
            dragHeight / 10.0 * (CGFloat(deep) + 1.0)
        case .some(false):
            deep == stackCount - 1 ? dragHeight : 0
        case .none:
            .zero
        }
        
        let offset = CGFloat(deep) * 10.0 - modulatedDragHeight * alignment.direction.sign
        
        return switch alignment.direction {
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

extension Alignment {
    enum Direction {
        case topToBottom, bottomToTop, unknown
        
        func isOpposite(_ scrollValue: CGFloat) -> Bool? {
            switch self {
            case .topToBottom: scrollValue < 0
            case .bottomToTop: scrollValue > 0
            case .unknown: nil
            }
        }
        
        var sign: CGFloat {
            switch self {
            case .topToBottom: 1.0
            case .bottomToTop: -1.0
            case .unknown: 0.0
            }
        }
    }
    
    var direction: Direction {
        switch self {
        case .top, .topLeading, .topTrailing, .leading, .trailing: .bottomToTop
        case .bottom, .bottomLeading, .bottomTrailing: .topToBottom
        default: .unknown
        }
    }
}
