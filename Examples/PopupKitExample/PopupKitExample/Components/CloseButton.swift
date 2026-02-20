//
//  CloseButton.swift
//  PopupKitExample
//
//  Created by Илья Аникин on 20.02.2026.
//


import SwiftUI

struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 15, height: 15)
                .padding(10)
                .background(.white.opacity(0.2), in: Circle())
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    CloseButton {
        print("Tap")
    }
}