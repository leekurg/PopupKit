//
//  ContentView.swift
//  SwiftUITest
//
//  Created by Илья Аникин on 28.07.2024.
//

import SwiftUI
import FullscreenOverlay

struct ContentView: View {
    var body: some View {
//        RootView()
//        MyRootView()
        OverlayTest()
    }
}

struct OverlayTest: View {
    @State private var isShow: Bool = false
    @State private var overlayPresenter = FullscreenOverlayPresenter()

    var body: some View {
        ZStack {
            Button("Show overlay") {
                isShow.toggle()
            }
            .buttonStyle(.borderedProminent)
            .fullscreenOverlay(isPresented: $isShow, axes: .vertical) {
                SearchView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .border(.red)
        .fullscreenOverlayRoot()
        .environment(overlayPresenter)
    }
}

struct SearchView: View {
    var body: some View {
        ScrollView {
            VStack {
                ForEach(1...15, id: \.self) { index in
                    Color.brown
                        .frame(height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .overlay(alignment: .leading) {
                            Text("\(index)").font(.title)
                                .padding(15)
                                .background(.ultraThinMaterial, in: Circle())
                                .padding(.horizontal)
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ContentView()
}
