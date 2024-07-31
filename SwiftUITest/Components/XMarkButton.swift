//
//  XMarkButton.swift
//  SwiftUITest
//
//  Created by Илья Аникин on 31.07.2024.
//

import SwiftUI

public struct XMarkButton: View {
    let action: () -> Void

    public init(size: CGFloat = 20.0, action: @escaping () -> Void) {
        self.action = action
        self.size = size
    }

    private let size: CGFloat
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .resizable()
                .frame(width: size * 0.65, height: size * 0.65)
                .fontWeight(.bold)
                .foregroundStyle(
                    colorScheme == .light ? .black.opacity(0.4) : .white.opacity(0.5)
                )
                .padding(size * 0.35)
                .background(
                    Circle().fill(
                        colorScheme == .light ? .black.opacity(0.1) : .white.opacity(0.2)
                    )
                )
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
    }
}

#Preview {
    XMarkButton(size: 50) { }
        .border(.red)
//        .preferredColorScheme(.dark)
}
