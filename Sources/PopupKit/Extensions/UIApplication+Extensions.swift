//
//  UIApplication+Extensions.swift
//
//
//  Created by Илья Аникин on 09.09.2024.
//

import SwiftUI

extension UIApplication {
    /// Returns an app's **PopupKit** HUD window if present.
    var popupKitWindow: PassThroughUIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .compactMap { $0 as? PassThroughUIWindow }
            .first
    }
    
    /// Returns an app's first key window if exists.
    var firstKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    /// Hides keyboard if presented.
    static func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
