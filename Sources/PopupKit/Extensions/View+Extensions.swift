//
//  View+Extensions.swift
//  PopupKit
//
//  Created by Илья Аникин on 02.10.2024.
//

import SwiftUI

extension View {
    func onKeyboardAppear(perform action: @escaping (Bool) -> Void) -> some View {
        onReceive(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true }
                .merge(
                    with: NotificationCenter.default
                        .publisher(for: UIResponder.keyboardWillHideNotification)
                        .map { _ in false }
                ),
            perform: action
        )
    }
}
