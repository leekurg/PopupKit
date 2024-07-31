//
//  FullscreenOverlay.swift
//  SwiftUITest
//
//  Created by Илья Аникин on 30.07.2024.
//

import SwiftUI

extension View {
    func fullscreenOverlay<Content: View, Background: ShapeStyle>(
        isPresented: Binding<Bool>,
        backgroundStyle: Background = .ultraThinMaterial,
        content: @escaping () -> Content
    ) -> some View {
        let closeButtonSize = 25.0
        let closeButtonPadding = 15.0
        
        let closeButton = Button {
            withAnimation(.spring) {
                isPresented.wrappedValue = false
            }
        } label: {
            Image(systemName: "xmark.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: closeButtonSize, height: closeButtonSize)
                .padding(closeButtonPadding)
        }
        .padding(.top, -(closeButtonSize + 2 * closeButtonPadding))
        
        return self
            .overlay {
                if isPresented.wrappedValue {
                    ZStack {
                        content()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(alignment: .topTrailing) {
                        closeButton
                    }
                    .background(backgroundStyle, ignoresSafeAreaEdges: .all)
//                    .border(.orange)
                    .transition(
                        .scale(scale: 1.5)
                        .combined(with: .opacity)
                    )
                }
            }
    }
}
