//
//  PopupKitAppDelegate.swift
//  
//
//  Created by Илья Аникин on 23.08.2024.
//

import SwiftUI

/// **PopupKit**'s designated **AppDelegate**.
///
/// Sets a ``PopupKit/PopupKitSceneDelegate`` as its scene delegate  for handling **PopupKit**'s presentation methods.
///
/// - Note: You can use your own class for delegation, as soon as it is inherited
/// from ``PopupKit/PopupKitSceneDelegate`` or doing it's job that needs to be done.
///
open class PopupKitAppDelegate: NSObject, UIApplicationDelegate {
    open func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = PopupKitSceneDelegate.self
        return sceneConfig
    }
}
