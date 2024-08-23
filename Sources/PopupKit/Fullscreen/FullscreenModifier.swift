//
//  FullscreenModifier.swift
//
//
//  Created by Илья Аникин on 23.08.2024.
//

import SwiftUI

public extension View {
    func fullscreen<Content: View>(
        isPresented: Binding<Bool>,
        content: @escaping () -> Content
    ) -> some View {
        #if DISABLE_POPUPKIT_IN_PREVIEWS
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            self
        } else {
            modifier(FullscreenModifier(isPresented: isPresented, overlay: content))
        }
        #else
        modifier(FullscreenModifier(isPresented: isPresented, fullscreen: content))
        #endif
    }
}

struct FullscreenModifier<T: View>: ViewModifier {
    @EnvironmentObject private var presenter: FullscreenPresenter
    
    @Binding var isPresented: Bool
    let fullscreen: () -> T
    
    @State private var overlayId = UUID()
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { presented in
                if presented {
                    dprint(presenter.isVerbose, "overlay [\(overlayId)]: present me 🤲")
                    let presentedId = presenter.present(id: overlayId, content: fullscreen)
                    if presentedId == nil { isPresented = false }
                } else {
                    if presenter.isStacked(overlayId) {
                        dprint(presenter.isVerbose, "overlay[\(overlayId)]: dismiss me 🫠")
                        presenter.dismiss(overlayId)
                    }
                }
            }
            .onChange(of: presenter.stack) { stack in
                if stack.find(overlayId) == nil { isPresented = false }
            }
    }
}
