//
//  NotificationView.swift
//  PopupKit
//
//  Created by Илья Аникин on 08.10.2024.
//

import SwiftUI

/// Default styled notification `View` with system image and text.
struct NotificationView: View {
    let notification: Notification
    
    private let inset = 5.0

    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: systemImage)
                .resizable()
                .renderingMode(.template)
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundStyle(color)
                .padding()
                .padding(.leading, inset)
            
            Text(notification.msg)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.vertical, .trailing])
        }
        .frame(maxWidth: .infinity, minHeight: 70)
        .background {
            RoundedRectangle(cornerRadius: 30)
                .fill(.thinMaterial)
                .overlay {
                    ContainerRelativeShape()
                        .stroke(color, lineWidth: 0.5)
                        .padding(inset)
                }
        }
        .containerShape(RoundedRectangle(cornerRadius: 30))
        .padding(.horizontal)
    }
    
    var color: Color {
        switch notification.role {
        case .success: .green
        case .info: .blue
        case .error: .red
        case .custom(_, let color): color
        }
    }
    
    var systemImage: String {
        switch notification.role {
        case .success: "checkmark.diamond"
        case .info: "info.square"
        case .error: "exclamationmark.octagon"
        case .custom(let icon, _): icon
        }
    }
}
