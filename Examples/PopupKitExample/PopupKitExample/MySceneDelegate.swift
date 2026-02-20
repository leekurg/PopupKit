//
//  MySceneDelegate.swift
//  PopupKitExample
//
//  Created by Илья Аникин on 23.08.2024.
//

import SwiftUI
import UIKit
import PopupKit

class MySceneDelegate: PopupKitSceneDelegate {
    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)
        print("MySceneDelegate is able to do it job")
    }
}
