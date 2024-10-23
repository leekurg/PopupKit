//
//  ActionImage.swift
//  PopupKit
//
//  Created by Илья Аникин on 23.10.2024.
//

import SwiftUI

/// Action image
public enum ActionImage {
    /// Create an `Image` from CFSymbols with system name.
    case systemName(String)
    /// Create an `Image` from the `UIKit` image.
    case uiImage(UIImage)
    /// Vanilla `SwiftUI` `Image`
    case image(Image)

    func buildImage() -> Image {
        switch self {
        case .systemName(let name):
            Image(systemName: name)
        case .uiImage(let uIImage):
            Image(uiImage: uIImage)
        case .image(let image):
            image
        }
    }
}
