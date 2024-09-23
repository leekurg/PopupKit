//
//  ConfirmAction.swift
//  PopupKit
//
//  Created by Илья Аникин on 23.09.2024.
//

import SwiftUI

public extension ConfirmPresenter {
    struct Action: Identifiable {
        public let id: UUID
        public let kind: Kind
        public let text: Text?
        public let image: Image?
        public let action: () -> Void
        
        init (id: UUID, kind: Kind, text: Text? = nil, image: Image? = nil, action: @escaping () -> Void) {
            self.id = id
            self.kind = kind
            self.text = text
            self.image = image
            self.action = action
        }
        
        public static func action(text: Text?, image: Image? = nil, action: @escaping () -> Void) -> Self {
            .init(id: UUID(), kind: .action, text: text, image: image, action: action)
        }
        
        public static func destructive(text: Text?, image: Image? = nil, action: @escaping () -> Void) -> Self {
            .init(id: UUID(), kind: .destructive, text: text, image: image, action: action)
        }
        
        public static func cancel(text: Text?, image: Image? = nil, action: (() -> Void)? = nil) -> Self {
            .init(id: UUID(), kind: .cancel, text: text, image: image, action: action ?? {})
        }
        
        static let `default`: Self = .cancel(text: Text(verbatim: "Cancel"))
    }
}

public extension ConfirmPresenter.Action {
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
    
    enum Kind {
        /// Regular action
        case action
        /// Destructive action, mark an action that deletes something permanently
        case destructive
        /// Cancel action, placed at list's bottom.
        case cancel
    }
}