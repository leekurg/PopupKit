//
//  PopupKitSceneDelegate.swift
//
//
//  Created by Илья Аникин on 23.08.2024.
//

import SwiftUI
import UIKit

/// **PopupKit**'s designated **SceneDelegate**.
///
/// Appends an additional windows to the app's scene, used by **PopupKit** for presentation methods.
/// It appends all  supported by **PipupKit** presentation layers. If you are not going to
/// use them all, you can make your own **SceneDelegate** class and configure presentation layers as it
/// suitable for you.
///
/// - Note: You can use your own class for delegation, as soon as it is inherited
/// from ``PopupKit/PopupKitSceneDelegate`` or doing it's job that needs to be done.
///
open class PopupKitSceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    private var notificationWindow: UIWindow?

    public lazy var coverPresenter = CoverPresenter()
    public lazy var fullscreenPresenter = FullscreenPresenter()
    public lazy var notificationPresenter = NotificationPresenter()
    
    open func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let scene = scene as? UIWindowScene {
            let notificationWindow = PassThroughUIWindow(windowScene: scene)

            let notificationViewController = UIHostingController(
                rootView: Color.clear
                    .coverRoot()
                    .ignoresSafeArea(.all, edges: [.all])
                    .fullscreenRoot()
                    .ignoresSafeArea(.all, edges: [.horizontal, .bottom])
                    .notificationRoot()
                    .environmentObject(coverPresenter)
                    .environmentObject(fullscreenPresenter)
                    .environmentObject(notificationPresenter)
            )

            notificationViewController.view.backgroundColor = .clear
            notificationWindow.rootViewController = notificationViewController
            notificationWindow.isHidden = false
            self.notificationWindow = notificationWindow
        }
    }
}
