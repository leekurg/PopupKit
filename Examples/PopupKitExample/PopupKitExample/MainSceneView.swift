//
//  MainSceneView.swift
//  PopupKitExample
//
//  Created by Илья Аникин on 23.08.2024.
//

import PopupKit
import SwiftUI

struct MainSceneView: View {
    @EnvironmentObject var sceneDelegate: MySceneDelegate

    var body: some View {
        ContentView()
            .environmentObject(sceneDelegate.coverPresenter)
            .environmentObject(sceneDelegate.fullscreenPresenter)
            .environmentObject(sceneDelegate.notificationPresenter)
            .environmentObject(sceneDelegate.confirmPresenter)
            .environmentObject(sceneDelegate.popupPresenter)
    }
}
