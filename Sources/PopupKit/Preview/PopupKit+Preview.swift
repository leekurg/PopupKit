//
//  PopupKit+Preview.swift
//
//
//  Created by Илья Аникин on 09.09.2024.
//

import SwiftUI

public enum PopupKitPreviewEnvironment {
    /// PopupKit environment for notification presentation within SwiftUI Preview system.
    public static var notification: Self = .notification(ignoredSafeAreaEdges: [])
    /// PopupKit environment for cover presentation within SwiftUI Preview system.
    public static var cover: Self = .cover(ignoredSafeAreaEdges: [.all])
    
    /// PopupKit environment for notification presentation within SwiftUI Preview system.
    case notification(ignoredSafeAreaEdges: Edge.Set)
    /// PopupKit environment for cover presentation within SwiftUI Preview system.
    case cover(ignoredSafeAreaEdges: Edge.Set)
    /// PopupKit environment for fullscreen presentation within SwiftUI Preview system.
    case fullscreen
}

public extension View {
    /// Injects a corresponding **Presenter** into `SwiftUI` environment and appropriate **rootModifier**
    /// to a view with PopupKit presentation when running in `SwiftUI` preview context.
    ///
    /// Use this modifier to prevent a `SwiftUI` Preview system from crashing when there is some calls to **PopupKit**
    /// presentation down the view hierarchy. It modifies view hierarchy in a safe way and **only** for SwiftUI Preview context.
    /// You can attach it to your view within **@Preview** macro, for example.
    ///
    /// - Note: To configure all environments at once you can use function ``previewPopupKit(ignoresSafeAreaEdges: Edge.Set)``
    /// - Note: Modifier do not make any changes to a view in **Release** builds.
    ///
    @ViewBuilder func previewPopupKit(_ env: PopupKitPreviewEnvironment) -> some View {
        switch env {
        case .notification(let ignoredSafeAreaEdges):
            self.modifier(NotificationPreviewEnvironment(ignoresSafeAreaEdges: ignoredSafeAreaEdges))
        case .cover(let ignoredSafeAreaEdges):
            self.modifier(CoverPreviewEnvironment(ignoresSafeAreaEdges: ignoredSafeAreaEdges))
        case .fullscreen:
            self.modifier(FullscreenPreviewEnvironment())
        }
    }
    
    /// Injects all **PopupKit**'s presenters into `SwiftUI` environment and also adds all needed **rootModifier**'s
    /// to a view when running in `SwiftUI` preview context.
    ///
    /// Use this modifier to prevent a `SwiftUI` Preview system from crashing when there is some calls to **PopupKit**
    /// presentation down the view hierarchy. It modifies view hierarchy in a safe way and **only** for SwiftUI Preview context.
    /// You can attach it to your view within **@Preview** macro, for example.
    ///
    /// - Note: To configure  environments in more flexible way you can use a set of functions
    /// ``previewPopupKit(_: PopupKitPreviewEnvironment)``.
    /// - Note: Modifier do not make any changes to a view in **Release** builds.
    ///
    func previewPopupKit(ignoresSafeAreaEdges: Edge.Set = []) -> some View {
        self
            .modifier(FullscreenPreviewEnvironment())
            .modifier(CoverPreviewEnvironment(ignoresSafeAreaEdges: ignoresSafeAreaEdges))
            .modifier(NotificationPreviewEnvironment(ignoresSafeAreaEdges: ignoresSafeAreaEdges))
    }
}
