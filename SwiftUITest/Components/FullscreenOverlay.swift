//
//  FullscreenOverlay.swift
//  SwiftUITest
//
//  Created by Илья Аникин on 30.07.2024.
//

import SwiftUI
import FullscreenOverlay

struct MyRootView: View {
    @State private var presenter = FullscreenPresenter()
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
        .environmentObject(presenter)
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
    @EnvironmentObject var presenter: FullscreenPresenter
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
