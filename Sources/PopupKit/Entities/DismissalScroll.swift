//
//  DismissalScroll.swift
//
//
//  Created by Илья Аникин on 09.09.2024.
//

import Foundation

/// Behaviour on scroll for some of presentation entries.
public enum DismissalScroll {
    /// Dissmiss a presentation entry after scroll down.
    case dismiss(predictedThreshold: CGFloat)
    /// No action.
    case none
    
    var predictedThreshold: CGFloat {
        switch self {
        case .dismiss(let predictedThreshold): predictedThreshold
        case .none: .zero
        }
    }
}
