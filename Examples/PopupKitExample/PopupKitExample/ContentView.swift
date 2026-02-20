//
//  ContentView.swift
//  PopupKitExample
//
//  Created by Илья Аникин on 20.02.2026.
//

import SwiftUI
import PopupKit

struct ContentView: View {
    @State var selectedTab: Tab = .notification
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NotificationTest()
                .tabItem {
                    Label("Notification", systemImage: "bell")
                }
                .tag(Tab.notification)
            
            FullscreenTest()
                .tabItem {
                    Label("Fullscreen", systemImage: "rectangle.portrait.inset.filled")
                }
                .tag(Tab.fullscreen)
            
            CoverTest()
                .tabItem {
                    Label("Cover", systemImage: "rectangle.portrait.bottomhalf.inset.filled")
                }
                .tag(Tab.cover)

            ConfirmTest()
                .tabItem {
                    Label("Confirm", systemImage: "rectangle.grid.1x2.fill")
                }
                .tag(Tab.confirm)

            PopupTest()
                .tabItem {
                    Label("Popup", systemImage: "rectangle.center.inset.fill")
                }
                .tag(Tab.popup)
        }
    }
}

extension ContentView {
    enum Tab {
        case notification
        case fullscreen
        case cover
        case confirm
        case popup
    }
}

#Preview {
    ContentView()
        .previewPopupKit(ignoresSafeAreaEdges: .bottom)
}
