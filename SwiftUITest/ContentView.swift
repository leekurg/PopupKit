//
//  ContentView.swift
//  SwiftUITest
//
//  Created by Илья Аникин on 28.07.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
//        RootView()
        MyRootView()
    }
}

struct FullscreenTest: View {
    @State private var isSearching = false
    @State private var isCapsule = false

    var body: some View {
        VStack {
            ScrollView {
                Color.red.frame(height: 200)
                Color.indigo.frame(height: 200)
                
                Button("Search") {
                    withAnimation(.spring) {
                        isSearching.toggle()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Capsule().fill(.cyan)
                    .frame(width: 300, height: 150)
                    .onTapGesture {
                        withAnimation(.spring) {
                            isCapsule.toggle()
                        }
                    }
                    .fullscreenOverlay(isPresented: $isCapsule) {
                        Circle()
                            .fill(.mint)
                    }
                
                Color.orange.frame(height: 200)
                Color.purple.frame(height: 200)
                
            }
        }
        .fullscreenOverlay(isPresented: $isSearching, backgroundStyle: .thinMaterial) {
            Text("Custom fullscreen")
                .font(.title)
        }
    }
}

struct RootView: View {
    @State private var overlayManager = FullscreenOverlayPresenter()
    
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
                
                ChildView()
                
                Color.brown.frame(height: 200)
                Color.blue.frame(height: 200)
                Color.orange.frame(height: 200)
            }
        }
        .fullscreenOverlayRoot()
        .fullscreenOverlay(isPresented: $isA) {
            Text("View A").font(.title)
        }
        .environment(overlayManager)
    }
}

struct ChildView: View {
    @State var isShow = false

    var body: some View {
        Button("Fullscreen on child") {
            isShow.toggle()
        }
        .buttonStyle(.borderedProminent)
        .padding(25)
        .background(.green, in: Capsule())
        .fullscreenOverlay(isPresented: $isShow) {
            Text("Child fullscreen presented")
                .font(.title)
        }
    }
}

#Preview {
    ContentView()
}
