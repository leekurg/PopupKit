//
//  Alignment+Extensions.swift
//
//
//  Created by Илья Аникин on 06.09.2024.
//

import SwiftUI

extension Alignment {
    func toUnitPoint() -> UnitPoint {
        switch self {
        case .bottom: .bottom
        case .bottomLeading: .bottomLeading
        case .bottomTrailing: .bottomTrailing
        case .top: .top
        case .topLeading: .topLeading
        case .topTrailing: .topTrailing
        case .leading: .leading
        case .trailing: .trailing
        default: .zero
        }
    }
    
    var opposite: Self {
        switch self {
        case .bottom: .top
        case .bottomLeading: .topTrailing
        case .bottomTrailing: .topLeading
        case .top: .bottom
        case .topLeading: .bottomTrailing
        case .topTrailing: .bottomLeading
        case .leading: .trailing
        case .trailing: .leading
        default: self
        }
    }
}
