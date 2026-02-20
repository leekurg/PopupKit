//
//  PopupKitExampleApp.swift
//  PopupKitExample
//
//  Created by Илья Аникин on 20.02.2026.
//

import SwiftUI

@main
struct PopupKitExampleApp: App {
    @UIApplicationDelegateAdaptor var adaptor: MyAppDelegate

    var body: some Scene {
        WindowGroup {
            MainSceneView()
        }
    }
}
