//
//  DefaultCoverBackground.swift
//
//
//  Created by Илья Аникин on 25.08.2024.
//

import SwiftUI

struct DefaultCoverBackground: ViewModifier {
    let variant: NotificationBackground
    
    func body(content: Content) -> some View {
        switch variant {
        case .default:
            content
                .frame(maxWidth: .infinity, minHeight: 100)
                .background {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.thinMaterial)
                        .overlay {
                            ContainerRelativeShape()
                                .stroke(.blue, lineWidth: 0.5)
                                .padding(5)
                        }
                }
                .containerShape(RoundedRectangle(cornerRadius: 30))
                .padding(.horizontal)
        case .none:
            content
        }
    }
}