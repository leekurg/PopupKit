//
//  PopupAction.swift
//  PopupKit
//
//  Created by Илья Аникин on 18.10.2024.
//

import SwiftUI

/// An action to present within **PopupKit**'s confirmation dialog.
/// An action holds optional text to present, optional image and closure to perform on tap.
///
/// Usage
/// ----
/// Use static members to init an action with dedicated **role**. There are 3 static initialisers for each of action's role:
/// - **cancel**: Action that hides the dialog without any changes or performed operations.
/// Cancel actions is listed at the bottom of the dialog actions list.
/// - **regular**: Action that performs some non-destructive operation.
/// - **destructive**: Action that performs some destructive operation.
///
public struct Action: Identifiable {
    public let id: UUID
    let role: Role
    let text: Text?
    let image: Image?
    let action: () -> Void
    
    init (id: UUID, role: Role, text: Text? = nil, image: Image? = nil, action: @escaping () -> Void) {
        self.id = id
        self.role = role
        self.text = text
        self.image = image
        self.action = action
    }
    
    public static func action(text: Text?, image: Image? = nil, action: @escaping () -> Void) -> Self {
        .init(id: UUID(), role: .regular, text: text, image: image, action: action)
    }
    
    public static func destructive(text: Text?, image: Image? = nil, action: @escaping () -> Void) -> Self {
        .init(id: UUID(), role: .destructive, text: text, image: image, action: action)
    }
    
    public static func cancel(text: Text?, image: Image? = nil, action: (() -> Void)? = nil) -> Self {
        .init(id: UUID(), role: .cancel, text: text, image: image, action: action ?? {})
    }
    
    static let `default`: Self = .cancel(text: Text(verbatim: "Cancel"))
}

public extension Action {
    /// Action image
    enum Image {
        /// Create an `Image` from CFSymbols with system name.
        case systemName(String)
        /// Create an `Image` from the `UIKit` image.
        case uiImage(UIImage)
        /// Vanilla `SwiftUI` `Image`
        case image(SwiftUI.Image)

        func buildImage() -> SwiftUI.Image {
            switch self {
            case .systemName(let name):
                SwiftUI.Image(systemName: name)
            case .uiImage(let uIImage):
                SwiftUI.Image(uiImage: uIImage)
            case .image(let image):
                image
            }
        }
    }
}

extension Action {
    /// A role which the action is used for.
    enum Role {
        /// Regular action
        case regular
        /// Destructive action, mark an action that deletes something permanently
        case destructive
        /// Cancel action, placed at list's bottom.
        case cancel
    }
}

struct SegregatedActions {
    let regular: [PopupKit.Action]
    let cancel: [PopupKit.Action]
    
    static let empty: Self = .init(regular: [], cancel: [])
}

extension Collection where Element == Action {
    /// Segregate a collection of actions and returns two collections: regular actions and cancel actions.
    func segregate() -> SegregatedActions {
        let regular = self.filter { $0.role != .cancel }
        let cancel = self.filter { $0.role == .cancel }
        
        return .init(regular: regular, cancel: cancel.isEmpty ? [.default] : cancel)
    }
}
