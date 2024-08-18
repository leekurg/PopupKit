//
//  MainSceneView.swift
//  SwiftUITest
//
//  Created by Илья Аникин on 17.08.2024.
//

import SwiftUI

struct MainSceneView: View {
    @EnvironmentObject var sceneDelegate: NotificationSceneDelegate

    var body: some View {
        ContentView()
            .environmentObject(sceneDelegate.notificationPresenter)
    }
}
