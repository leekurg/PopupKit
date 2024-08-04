//
//  NotificationRootModifier.swift
//  SwiftUITest
//
//  Created by Илья Аникин on 03.08.2024.
//

import SwiftUI

public extension View {
    func notificationRoot(
        alignment: Alignment = .bottom,
        transition: AnyTransition = .notification
    ) -> some View {
        modifier(
            NotificationRootModifier(
                alignment: alignment,
                transition: transition
            )
        )
    }
}

public extension AnyTransition {
    static let notification: AnyTransition = .asymmetric(
        insertion: .move(edge: .bottom),
        removal: .move(edge: .bottom).combined(with: .opacity)
    )
}

struct NotificationRootModifier: ViewModifier {
    @Environment(NotificationPresenter.self) private var presenter
//    @State private var orientation = DeviceOrientation()
    
    let alignment: Alignment
    let transition: AnyTransition

    private let closeButtonSize = 20.0
    private let closeButtonPadding = 15.0

    func body(content: Content) -> some View {
        content
            .overlay {
                    ZStack {
                        ForEach(presenter.stack) { entry in
                            VStack {
                                entry.view
                            }
                            .frame(maxWidth: 500, minHeight: 100)
                            .background {
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(.thinMaterial)
//                                    .fill(.gray.opacity(0.5))
                                    .overlay {
                                        ContainerRelativeShape()
                                            .stroke(.blue, lineWidth: 0.5)
                                            .padding(5)
                                    }
                            }
                            .containerShape(RoundedRectangle(cornerRadius: 30))
                            .padding()
                            .zIndex(Double(entry.deep))
                            .offset(
//                                calcOffset(deep: entry.deep, alignment: alignment)
                                calcOffset(
                                    deep: presenter.stack.firstIndex { $0.id == entry.id } ?? 0,
                                    alignment: alignment
                                )
                            )
                            .scaleEffect(
//                                calcScale(
//                                    deep: entry.deep,
//                                    total: presenter.stack.count
//                                )
                                calcScale(
                                    deep: presenter.stack.firstIndex { $0.id == entry.id } ?? 0,
                                    total: presenter.stack.count
                                )
                            )
                            .blur(
//                                radius: calcBlur(
//                                    deep: entry.deep,
//                                    total: presenter.stack.count
//                                )
                                radius: calcBlur(
                                    deep: presenter.stack.firstIndex { $0.id == entry.id } ?? 0,
                                    total: presenter.stack.count
                                )
                            )
                            .transition(transition)
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: alignment
                    )
//                    .border(.green)
            }
    }
    
    private func calcOffset(deep: Int, alignment: Alignment) -> CGSize {
        let offset = deep * 10
        
        return switch alignment {
        case .top, .topLeading, .topTrailing: CGSize(width: 0, height: offset)
        case .bottom, .bottomLeading, .bottomTrailing: CGSize(width: 0, height: -offset)
        case .leading: CGSize(width: offset, height: 0)
        case .trailing: CGSize(width: -offset, height: 0)
        default: .zero
        }
    }
    
    /// Only last is showing fullsized, after hide previous scaled up
//    private func calcScale(index: Int?, total: Int) -> CGSize {
//        guard let index, /*index > 0,*/ total > 0 else {
//            print("index \(index)/\(total): \(1)")
//            return CGSize(width: 1, height: 1)
//        }
//
//        let t: Double = Double(total)
//        let i: Double = Double(index)
//        let scale = (i+1) / t
//        
//        print("index \(index)/\(total): \(scale)")
//        
//        return CGSize(width: scale, height: scale)
//    }
    
    private func calcScale(deep: Int, total: Int) -> CGSize {
        let scale: Double = 1.0 - 0.05 * (Double(total) - (Double(deep) + 1.0))
        
        return CGSize(width: scale, height: scale)
    }
    
    private func calcBlur(deep: Int, total: Int) -> CGFloat {
        Double(total) - Double(deep) - 1.0
    }
}

#Preview {
    ContentView()
}
