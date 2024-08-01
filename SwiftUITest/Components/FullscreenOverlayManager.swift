//
//  FullscreenOverlayManager.swift
//  SwiftUITest
//
//  Created by Илья Аникин on 30.07.2024.
//

import SwiftUI

// MARK: - Presenter
@Observable public class FullscreenOverlayPresenter {
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
        
        stack.append(StackEntry(id: id, deep: (stack.last?.deep ?? 0) + 1, view: AnyView(content())))
        print("✅ presenting \(id)")
        return id
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
    
    func isStacked(_ id: UUID) -> Bool {
        stack.find(id) != nil
    }
    
    func popToRoot() {
        stack.removeAll()
    }
    
    func popFirst() {
        stack.removeFirst()
    }
    
    func popLast() {
        stack.removeLast()
    }
}

extension FullscreenOverlayPresenter {
    struct StackEntry: Identifiable, Equatable {
        let id: UUID
        let deep: Int
        let view: AnyView
        
        static func == (lhs: StackEntry, rhs: StackEntry) -> Bool {
            lhs.id == rhs.id
        }
    }
}

fileprivate extension Array where Element == FullscreenOverlayPresenter.StackEntry {
    func find(_ entryId: UUID) -> FullscreenOverlayPresenter.StackEntry? {
        first { $0.id == entryId }
    }
}

// MARK: - Overlay
struct FullscreenOverlay<Overlay: View>: ViewModifier {
    @Environment(FullscreenOverlayPresenter.self) private var presenter
    @Environment(\.overlayTransitionAnimation) private var transitionAnimation
    
    @Binding var isPresented: Bool
    let overlay: () -> Overlay
    
    @State private var overlayId = UUID()
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) {
                if isPresented {
                    print("overlay [\(overlayId)]: present me 🤲")
                    var presentedId: UUID?
                    withAnimation(transitionAnimation.insertion) {
                        presentedId = presenter.present(id: overlayId, content: overlay)
                    }
                    if presentedId == nil { isPresented = false }
                } else {
                    if presenter.isStacked(overlayId) {
                        print("overlay[\(overlayId)]: dismiss me 🫠")
                        withAnimation(transitionAnimation.removal) {
                            presenter.dismiss(overlayId)
                        }
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
struct FullscreenStack: ViewModifier {
    @Environment(FullscreenOverlayPresenter.self) private var presenter
    @Environment(\.overlayTransitionAnimation) var transitionAnimation
    
    let transition: AnyTransition

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
                                        withAnimation(transitionAnimation.removal) {
                                            presenter.dismiss(entry.id)
                                        }
                                    }
                                    .padding(closeButtonPadding)
                                    //TODO: support orientation change
//                                    .padding(.top, -(closeButtonSize + 2 * closeButtonPadding))
                                }
                                .zIndex(Double(entry.deep))
                                .background(.ultraThinMaterial, ignoresSafeAreaEdges: .all)
                                .transition(transition)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(transition)
                }
            }
    }
}

// MARK: - Environment
extension EnvironmentValues {
    var overlayTransitionAnimation: OverlayTransitionAnimation {
        get { self[OverlayTransitionAnimationKey.self] }
        set { self[OverlayTransitionAnimationKey.self] = newValue }
    }
}

fileprivate struct OverlayTransitionAnimationKey: EnvironmentKey {
    static let defaultValue: OverlayTransitionAnimation = .init(
        insertion: .spring(duration: 0.5),
        removal: .linear(duration: 0.3)
     )
}

struct OverlayTransitionAnimation {
    let insertion: Animation
    let removal: Animation
}

// MARK: - View
public extension AnyTransition {
    static let fullscreenOverlay: AnyTransition = .scale(scale: 1.5).combined(with: .opacity)
}

public extension View {
    func fullscreenOverlayRoot(_ transition: AnyTransition = .fullscreenOverlay) -> some View {
        modifier(FullscreenStack(transition: transition))
    }
    
    func fullscreenOverlay<Content: View>(
        isPresented: Binding<Bool>,
        content: @escaping () -> Content
    ) -> some View {
        modifier(FullscreenOverlay(isPresented: isPresented, overlay: content))
    }
}

// MARK: - Test Views
struct MyRootView: View {
    @State private var presenter = FullscreenOverlayPresenter()
    @State private var isA = false
    @State private var isB = false

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
                    
                    Button("View B") {
                        isB.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Color.brown.frame(height: 200)
                Color.blue.frame(height: 200)
                Color.orange.frame(height: 200)
            }
        }
        .fullscreenOverlayRoot()
        .fullscreenOverlay(isPresented: $isA) {
            ViewA()
        }
        .fullscreenOverlay(isPresented: $isB) {
            ViewB()
        }
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
        .fullscreenOverlay(isPresented: $isB) {
            ViewB()
        }
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
        .fullscreenOverlay(isPresented: $isC) {
            ViewC()
        }
    }
}

struct ViewC: View {
    @State var isB = false
    @Environment(FullscreenOverlayPresenter.self) var presenter
    @Environment(\.overlayTransitionAnimation) var overlayTransitionAnimation

    var body: some View {
        VStack {
            Text("View C")
            
            Rectangle().fill(.pink)
                .frame(width: 100, height: 200)
            
            Button("Pop to root") {
                withAnimation(.spring) {
                    presenter.popToRoot()
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button("Pop first") {
                withAnimation(overlayTransitionAnimation.removal) {
                    presenter.popFirst()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}


#Preview {
    MyRootView()
}
