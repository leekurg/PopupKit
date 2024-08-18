//
//  NotificationAppDelegate.swift
//  SwiftUITest
//
//  Created by Илья Аникин on 17.08.2024.
//

import UIKit

class NotificationAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = NotificationSceneDelegate.self
        return sceneConfig
    }
}
