//
//  PopupKitHostingController.swift
//
//
//  Created by Илья Аникин on 09.09.2024.
//

import SwiftUI

/// Subclass of ``UIHostingController`` used by PopupKit.
///
/// Posts a notification when its safe area changes (e.g. after device orientation change).
/// - Note: PopupKit window ``PassThroughUIWindow`` requires to use instance of this class as its **rootViewController**
/// when you are using PopupKit fullscreen presentation. This requirement were made due to proper handling of safe area changes
/// within fullscreen presentation entries.
///
open class PopupKitHostingController<Content>: UIHostingController<Content> where Content: View {
    open override func viewSafeAreaInsetsDidChange() {
        NotificationCenter.default.post(
            name: .popupKitSafeAreaChangedNotification,
            object: UIApplication.shared.popupKitWindow?.safeAreaInsets.toSwiftUIInsets
        )
    }
}

extension Notification.Name {
    static let popupKitSafeAreaChangedNotification = Notification.Name("PopupKitSafeAreaChangedNotification")
}

extension UIEdgeInsets {
    var toSwiftUIInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}
