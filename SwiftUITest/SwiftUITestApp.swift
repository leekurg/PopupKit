//
//  SwiftUITestApp.swift
//  SwiftUITest
//
//  Created by Илья Аникин on 28.07.2024.
//

import SwiftUI

@main
struct SwiftUITestApp: App {
    @UIApplicationDelegateAdaptor var adaptor: NotificationAppDelegate

    var body: some Scene {
        WindowGroup {
            MainSceneView()
        }
    }
}
