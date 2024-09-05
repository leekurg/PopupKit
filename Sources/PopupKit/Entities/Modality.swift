//
//  Modality.swift
//
//
//  Created by Илья Аникин on 05.09.2024.
//

import Foundation

/// A view modality mode.
///
/// A view can be modal (``Modality\modal(_)``) or non-modal (``Modality\none``).
/// Non-modal view does not block user interaction with underlying views.
/// Modal presentable entry blocks user interaction with underlying views.
/// Also, modality can be interactive(``Interactivity\interactive``) and non-interactive(``Interactivity\noninteractive``).
/// Interactive modal view allows the user to interact with it(e.g.. swipe down to close), non-interactive modal do not.
public enum Modality {
    /// Interactivity of modal view is defined by **interactivity**.
    case modal(interactivity: Interactivity)
    /// Non-modal view
    case none
    
    /// Indicates when current modality allows user interction.
    var isInteractive: Bool {
        switch self {
        case .modal(let interactivity):
            switch interactivity {
            case .interactive: true
            case .noninteractive: false
            }
        case .none: true
        }
    }
}

public extension Modality {
    /// Interactivity of modal view.
    enum Interactivity {
        /// Modal view is interactive.
        case interactive
        /// Modal view is non-interactive.
        case noninteractive
    }
}
