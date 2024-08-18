//
//  NotificationSceneDelegate.swift
//  SwiftUITest
//
//  Created by Илья Аникин on 17.08.2024.
//

import SwiftUI
import UIKit
import PopupKit

class NotificationSceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    private var notificationWindow: UIWindow?
    public lazy var notificationPresenter = NotificationPresenter()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let scene = scene as? UIWindowScene {
            let notificationWindow = PassThroughWindow(windowScene: scene)

            let notificationViewController = UIHostingController(
                rootView: Color.clear
                    .notificationRoot()
                    .ignoresSafeArea(.all, edges: [.horizontal, .bottom])
                    .environmentObject(notificationPresenter)
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
