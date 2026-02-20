//
//  FullscreenTest.swift
//  PopupKitExample
//
//  Created by Илья Аникин on 23.08.2024.
//

import PopupKit
import SwiftUI

struct FullscreenTest: View {
    @State private var f1 = false
    @State private var f2 = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.red.opacity(0.8)
                
                VStack {
                    Button("PopupKit fullscreen") {
                        f1.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    VStack(spacing: 3) {
                        Button("PopupKit fullscreen") {
                            f2.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Text("igonring bottom safe area edge")
                            .font(.caption2)
                    }
                }
            }
            .fullscreen(
                isPresented: $f1,
                background: .ultraThinMaterial
            ) {
                ViewA(deep: 0)
            }
            .fullscreen(
                isPresented: $f2,
                background: .ultraThinMaterial,
                ignoresEdges: .bottom
            ) {
                ViewA(deep: 0)
            }
            .ignoresSafeArea()
            .navigationTitle("Fullscreen")
        }
        .fullscreen(isPresented: $f1, background: .ultraThinMaterial) {
            ViewA(deep: 1)
        }
    }
}

fileprivate struct ViewA: View {
    let deep: Int
    @State var f1 = false
    
    @EnvironmentObject var presenter: FullscreenPresenter

    var body: some View {
        VStack {
            Text("Fullscreen #\(deep)")
                .font(.system(.title, design: .monospaced))

            HStack {
                Button("Next fullscreen") {
                    f1.toggle()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .border(.blue)
        .overlay(alignment: .topLeading) {
            Text("respects safe area")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.blue)
        }
        .overlay(alignment: .topTrailing) {
            CloseButton {
                presenter.popLast()
            }
            .padding()
        }
        .fullscreen(isPresented: $f1, background: .ultraThinMaterial) {
            ViewA(deep: deep + 1)
        }
    }
}

#Preview {
    FullscreenTest()
        .previewPopupKit(.fullscreen)
}
