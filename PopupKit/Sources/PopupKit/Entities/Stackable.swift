//
//  Stackable.swift
//
//
//  Created by Илья Аникин on 23.08.2024.
//

import Foundation
import SwiftUI

public protocol Stackable: Identifiable, Equatable {
    /// id of the presentable entity
    var id: UUID { get }
    /// Deep level of the presentable entity within the stack
    var deep: Int { get }
    /// Content of the presentable entity
    var view: AnyView { get }
    
    static func == (lhs: Self, rhs: Self) -> Bool
}

public extension Stackable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
