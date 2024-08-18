//
//  DismissDirection.swift
//  SwiftUITest
//
//  Created by Илья Аникин on 18.08.2024.
//

import SwiftUI

/// Describes a direction of swipe, needed to dismiss a view.
enum DismissDirection {
    case topToBottom, bottomToTop, unknown
    
    init(alignment: Alignment) {
        self = switch alignment {
        case .top, .topLeading, .topTrailing, .leading, .trailing: .bottomToTop
        case .bottom, .bottomLeading, .bottomTrailing: .topToBottom
        default: .unknown
        }
    }
    
    func isForward(_ scrollValue: CGFloat) -> Bool? {
        switch self {
        case .topToBottom: scrollValue > 0
        case .bottomToTop: scrollValue < 0
        case .unknown: nil
        }
    }
    
    var sign: CGFloat {
        switch self {
        case .topToBottom: 1.0
        case .bottomToTop: -1.0
        case .unknown: 0.0
        }
    }
}

