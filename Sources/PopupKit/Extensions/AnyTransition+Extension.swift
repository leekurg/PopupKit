//
//  AnyTransition+Extension.swift
//  PopupKit
//
//  Created by Илья Аникин on 18.08.2024.
//

import SwiftUI

public extension AnyTransition {
    static let notification: AnyTransition = .asymmetric(
        insertion: .move(edge: .bottom),
        removal: .move(edge: .bottom).combined(with: .opacity)
    )
    
    static let fullscreen: AnyTransition = .scale(scale: 1.5).combined(with: .opacity)
}
