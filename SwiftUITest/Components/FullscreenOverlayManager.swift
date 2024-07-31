//
//  FullscreenOverlayManager.swift
//  SwiftUITest
//
//  Created by Илья Аникин on 30.07.2024.
//

import SwiftUI

@Observable public class FullscreenOverlayPresenter {
    private(set) var presentingId: UUID?
    private(set) var presentingContent: AnyView?
    
    public init() { }
    
    func present<Content: View>(id: UUID, content: @escaping () -> Content) {
        presentingId = id
        presentingContent = AnyView(content())
    }
    
    func dismiss() {
        presentingId = nil
        presentingContent = nil
    }
}

struct FullscreenOverlay<Overlay: View>: ViewModifier {
    @Environment(FullscreenOverlayPresenter.self) var manager
    
    @Binding var isPresented: Bool
    let overlay: () -> Overlay
    
    @State private var overlayId = UUID()
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { oldPresented, presented in
                // No presentation at the moment
                if manager.presentingId == nil {
                    withAnimation(.spring) {
                        presented
                            ? manager.present(id: overlayId, content: overlay)
                            : manager.dismiss()
                    }
                    return
                }
                
                // Some presentation is there
                if manager.presentingId == overlayId {
                    // It's this presentation
                    if !presented { withAnimation(.spring) { manager.dismiss() } }
                    return
                }

                // It's another presentation - ignore & set isPresented to false
                // Warning! Carefuly check for possible recursion
                isPresented = oldPresented
            }
            .onChange(of: manager.presentingId) { oldValue, newValue in
                if oldValue == overlayId && newValue == nil {
                    isPresented = false
                }
            }
    }
}

/// View modifier for presenting overlays.
struct FullscreenPresenter: ViewModifier {
    @Environment(FullscreenOverlayPresenter.self) private var manager

    private let closeButtonSize = 20.0
    private let closeButtonPadding = 15.0

    func body(content: Content) -> some View {
        content
            .overlay {
                if let content = manager.presentingContent {
                    ZStack {
                        content
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(alignment: .topTrailing) {
                        XMarkButton(size: closeButtonSize) {
                            withAnimation(.spring) { manager.dismiss() }
                        }
                        .padding(closeButtonPadding)
                        //TODO: orientation
//                        .padding(.top, -(closeButtonSize + 2 * closeButtonPadding))
                    }
                    .background(.ultraThinMaterial, ignoresSafeAreaEdges: .all)
                    .transition(
                        .scale(scale: 1.5)
                        .combined(with: .opacity)
                    )
                }
            }
            .statusBarHidden(manager.presentingId != nil)
    }
}

public extension View {
    func fullscreenOverlayRoot() -> some View {
        modifier(FullscreenPresenter())
    }
    
    func fullscreenOverlay<Content: View>(
        isPresented: Binding<Bool>,
        content: @escaping () -> Content
    ) -> some View {
        modifier(FullscreenOverlay(isPresented: isPresented, overlay: content))
    }
}

// MARK: - Stack



// MARK: - Presenter
@Observable public class OverlayStackPresenter {
    //    private(set) var path: [Destination: () -> AnyView] = [:]
    private(set) var stack: [StackEntry] = []
    
    public init() { }
    
    /// Present a *content* with given **id**.
    ///
    /// - Returns: Returns presenting 'Destination' or **nil** when **id** is in stack already.
    ///
    func present<Content: View>(id: UUID, content: @escaping () -> Content) -> UUID? {
        if let _ = stack.find(id) {
            print("⚠️ id is already in stack - skip")
            return nil
        }
        
        stack.append(StackEntry(id: id, view: AnyView(content())))
        print("✅ presenting \(id)")
        return id
    }
    
    func isPresented(_ id: UUID) -> Bool {
        stack.find(id) != nil
    }
    
    func dismiss(_ id: UUID) {
        let presentedIndex = stack.firstIndex { $0.id == id }
        
        if let presentedIndex {
            stack.remove(at: presentedIndex)
            print("🙈 dismiss \(id)")
        } else {
            print("⚠️ id \(id) is not found in hierarchy - skip")
        }
    }
}

extension Array where Element == OverlayStackPresenter.StackEntry {
    func find(_ entryId: UUID) -> OverlayStackPresenter.StackEntry? {
        first { $0.id == entryId }
    }
}

extension OverlayStackPresenter {
    struct StackEntry: Identifiable, Equatable {
        let id: UUID
        let view: AnyView
        
        static func == (lhs: StackEntry, rhs: StackEntry) -> Bool {
            lhs.id == rhs.id
        }
    }
}

// MARK: - Overlay
struct _FullscreenOverlay<Overlay: View>: ViewModifier {
    @Environment(OverlayStackPresenter.self) var presenter
    
    @Binding var isPresented: Bool
    let overlay: () -> Overlay
    
    @State private var overlayId = UUID()
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) {
                if isPresented {
                    print("overlay [\(overlayId)]: present me 🤲")
                    var presentedId: UUID?
                    withAnimation(.spring) {
                        presentedId = presenter.present(id: overlayId, content: overlay)
                    }
                    if presentedId == nil { isPresented = false }
                } else {
                    if presenter.isPresented(overlayId) {
                        print("overlay[\(overlayId)]: dismiss me 🫠")
                        withAnimation(.spring) { presenter.dismiss(overlayId) }
                    }
                }
            }
            .onChange(of: presenter.stack) {
                if presenter.stack.find(overlayId) == nil { isPresented = false }
            }
    }
}

// MARK: - Stack
/// View modifier for presenting overlays.
struct _FullscreenStack: ViewModifier {
    @Environment(OverlayStackPresenter.self) private var presenter

    private let closeButtonSize = 20.0
    private let closeButtonPadding = 15.0

    func body(content: Content) -> some View {
        content
            .overlay {
                if !presenter.stack.isEmpty {
                    ZStack {
                        ForEach(presenter.stack) { entry in
                            entry.view
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .overlay(alignment: .topTrailing) {
                                    XMarkButton(size: closeButtonSize) {
                                        withAnimation(.spring) { presenter.dismiss(entry.id) }
                                    }
                                    .padding(closeButtonPadding)
                                    //TODO: orientation
                                    //                        .padding(.top, -(closeButtonSize + 2 * closeButtonPadding))
                                }
                                .zIndex(Double(presenter.stack.firstIndex { $0.id == entry.id } ?? 0))
                                .background(.ultraThinMaterial, ignoresSafeAreaEdges: .all)
                                .transition(
                                    .scale(scale: 1.5)
                                    .combined(with: .opacity)
                                )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(
                        .scale(scale: 1.5)
                        .combined(with: .opacity)
                    )
                }
            }
    }
}

//public extension View {
//    func fullscreenOverlayRoot() -> some View {
//        modifier(FullscreenPresenter())
//    }
//    
//    func fullscreenOverlay<Content: View>(
//        isPresented: Binding<Bool>,
//        content: @escaping () -> Content
//    ) -> some View {
//        modifier(FullscreenOverlay(isPresented: isPresented, overlay: content))
//    }
//}

// MARK: - View
//struct MyRootView: View {
//    @State var presenter = OverlayStackPresenter()
//    @State var isA = false
//
//    var body: some View {
//        Button("View A") {
//            isA.toggle()
//        }
//        .buttonStyle(.borderedProminent)
//        .modifier(_FullscreenStack())
//        .modifier(_FullscreenOverlay(isPresented: $isA, overlay: {
//            ViewA()
//        }))
//        .environment(presenter)
//    }
//}

struct MyRootView: View {
    @State private var presenter = OverlayStackPresenter()
    @State private var isA = false

    var body: some View {
        VStack {
            ScrollView {
                Color.red.frame(height: 200)
                Color.mint.frame(height: 200)
                
                HStack {
                    Button("View A") {
                        isA.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Circle().fill(isA ? .green : .red)
                        .frame(width: 20)
                }
                
                Color.brown.frame(height: 200)
                Color.blue.frame(height: 200)
                Color.orange.frame(height: 200)
            }
        }
        .modifier(_FullscreenStack())
        .modifier(_FullscreenOverlay(isPresented: $isA, overlay: {
            ViewA()
        }))
        .environment(presenter)
    }
}

struct ViewA: View {
    @State var isB = false

    var body: some View {
        VStack {
            Text("View A")
            
            Circle().fill(.mint)
                .frame(width: 100, height: 100)
            
            Button("View B") {
                isB.toggle()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxHeight: .infinity)
        .modifier(_FullscreenOverlay(isPresented: $isB, overlay: {
            ViewB()
        }))
    }
}

struct ViewB: View {
    @State var isC = false

    var body: some View {
        VStack {
            Text("View B")
            
            Capsule().fill(.indigo)
                .frame(width: 200, height: 100)
            
            Button("View C") {
                isC.toggle()
            }
            .buttonStyle(.borderedProminent)
        }
        .modifier(_FullscreenOverlay(isPresented: $isC, overlay: {
            ViewC()
        }))
    }
}

struct ViewC: View {
    @State var isB = false

    var body: some View {
        VStack {
            Text("View C")
            
            Rectangle().fill(.pink)
                .frame(width: 100, height: 200)
            
//            Button("View B") {
//                isB.toggle()
//            }
//            .buttonStyle(.borderedProminent)
        }
    }
}


#Preview {
    MyRootView()
}
