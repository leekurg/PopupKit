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
    
    @State private var fullscreenId = UUID()
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { presented in
                if presented {
                    dprint(presenter.isVerbose, "overlay [\(fullscreenId)]: present me 🤲")
                    let presentedId = presenter.present(id: fullscreenId, content: fullscreen)
                    if presentedId == nil { isPresented = false }
                } else {
                    if presenter.isStacked(fullscreenId) {
                        dprint(presenter.isVerbose, "overlay[\(fullscreenId)]: dismiss me 🫠")
                        presenter.dismiss(fullscreenId)
                    }
                }
            }
            .onChange(of: presenter.stack) { stack in
                Task {
                    if stack.find(fullscreenId) == nil { isPresented = false }
                }
            }
    }
}
