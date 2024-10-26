//
//  ActionRole.swift
//  PopupKit
//
//  Created by Илья Аникин on 23.10.2024.
//

/// A role which the action is used for.
public enum ActionRole {
    /// Regular action
    case regular
    /// Destructive action, mark an action that deletes something permanently
    case destructive
    /// Cancel action, placed at list's bottom.
    case cancel
}
