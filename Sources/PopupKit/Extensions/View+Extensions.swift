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
    
    func receiveInsetsOnOrientationChange(perform action: @escaping (EdgeInsets) -> Void) -> some View {
        onReceive(
            NotificationCenter.default
                .publisher(for: UIDevice.orientationDidChangeNotification)
                .receive(on: RunLoop.main)
                .map { _ in UIDevice.current.orientation }
                .filter { current in
                    [
                        UIDeviceOrientation.portrait,
                        UIDeviceOrientation.landscapeLeft,
                        UIDeviceOrientation.landscapeRight
                    ]
                    .contains(current)
                }
                .compactMap { _ in
                    UIApplication.shared
                        .firstKeyWindow?
                        .safeAreaInsets
                        .toSwiftUIInsets
                }
                .removeDuplicates(),
            perform: action
        )
    }
    
    func receiveInsetsOnAppBecameActive(perform action: @escaping (EdgeInsets) -> Void) -> some View {
        onReceive(
            NotificationCenter.default
                .publisher(for: UIApplication.didBecomeActiveNotification)
                .receive(on: RunLoop.main)
                .compactMap { _ in
                    UIApplication.shared
                        .firstKeyWindow?
                        .safeAreaInsets
                        .toSwiftUIInsets
                }
                .removeDuplicates(),
            perform: action
        )
    }
}
