//
//  Action.swift
//  PopupKit
//
//  Created by Илья Аникин on 18.10.2024.
//

import SwiftUI

/// An action to present within **PopupKit**'s presentation modes.
/// Action holds optional text to present, optional image and closure to perform on tap.
///
/// Usage
/// ----
/// Use built-in types to initialize an action with specified **role**.
/// There are 3 built-in types to express an action:
/// - ``Regular()``: Action that performs some non-destructive operation.
/// - ``Destructive()``: Action that performs some destructive operation.
/// - ``Cancel()``: Action that hides the dialog without any changes or performed operations.
/// Cancel actions is listed at the bottom of the dialog/popup alert actions list.
///
public protocol Action {
    var id: UUID { get }
    var role: ActionRole { get }
    var text: Text? { get }
    var image: ActionImage? { get }
    var action: () -> Void { get }
}

/// An action with **.regular** role and appearance.
///
/// See ``PopupKit/Action`` to know more.
///
public struct Regular: Action {
    public let id: UUID = UUID()
    public let role: ActionRole = .regular
    public let text: Text?
    public let image: ActionImage?
    public let action: () -> Void

    public init(text: Text?, image: ActionImage? = nil, action: @escaping () -> Void) {
        self.text = text
        self.image = image
        self.action = action
    }
}

/// An action with **.destructive** role and appearance.
///
/// See ``PopupKit/Action`` to know more.
///
public struct Destructive: Action {
    public let id: UUID = UUID()
    public let role: ActionRole = .destructive
    public let text: Text?
    public let image: ActionImage?
    public let action: () -> Void

    public init(text: Text?, image: ActionImage? = nil, action: @escaping () -> Void) {
        self.text = text
        self.image = image
        self.action = action
    }
}

/// An action with **.cancel** role and appearance.
///
/// See ``PopupKit/Action`` to know more.
///
public struct Cancel: Action {
    public let id: UUID = UUID()
    public let role: ActionRole = .cancel
    public let text: Text?
    public let image: ActionImage?
    public let action: () -> Void

    public init(text: Text?, image: ActionImage? = nil, action: (() -> Void)? = nil) {
        self.text = text
        self.image = image
        self.action = action ?? {}
    }
}

@resultBuilder public struct ActionBuilder {
    public static func buildBlock(_ components: Action...) -> [Action] {
        components
    }
}

struct SegregatedActions {
    let regular: [Action]
    let cancel: [Action]

    var count: Int { regular.count + cancel.count }

    static let empty: Self = .init(regular: [], cancel: [])
}

extension Collection where Element == Action {
    /// Segregate a collection of actions and returns two collections: regular actions and cancel actions.
    func segregate() -> SegregatedActions {
        let regular = self.filter { $0.role != .cancel }
        let cancel = self.filter { $0.role == .cancel }

        return .init(
            regular: self.isEmpty ? [Cancel(text: Text(verbatim: "Ok"))] : regular,
            cancel: cancel)
    }
}
