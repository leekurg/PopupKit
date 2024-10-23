//
//  ActionContext.swift
//  PopupKit
//
//  Created by Илья Аникин on 20.10.2024.
//

/// A context-specific properties of **PopupKit**'s actions presentation
enum ActionContext {
    case alert
    case confirm
    
    var height: Double {
        switch self {
        case .alert: 45.0
        case .confirm: 60.0
        }
    }
}
