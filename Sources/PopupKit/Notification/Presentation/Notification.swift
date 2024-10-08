//
//  Notification.swift
//  PopupKit
//
//  Created by Илья Аникин on 08.10.2024.
//

import SwiftUI

/// Default set of data to present a **PopupKit**'s notification.
///
/// Type provides a set of predefined static initializers for use. You can easely extend
/// this type by providing you own static initializers using **.custom()** init.
/// 
public struct Notification: Identifiable, Equatable {
    public let id: UUID
    public let msg: String
    let role: Role
    
    private init(id: UUID, role: Role, msg: String) {
        self.id = id
        self.role = role
        self.msg = msg
    }
    
    public static func success(_ msg: String) -> Self {
        Self(id: UUID(), role: .success, msg: msg)
    }
    
    public static func error(_ msg: String) -> Self {
        Self(id: UUID(), role: .error, msg: msg)
    }
    
    public static func info(_ msg: String) -> Self {
        Self(id: UUID(), role: .info, msg: msg)
    }
    
    public static func custom(_ msg: String, systemImage: String = "gear", color: Color = .primary) -> Self {
        Self(id: UUID(), role: .custom(systemImage: systemImage, color: color), msg: msg)
    }
    
    enum Role: Equatable {
        case success
        case info
        case error
        case custom(systemImage: String, color: Color)
    }
}
