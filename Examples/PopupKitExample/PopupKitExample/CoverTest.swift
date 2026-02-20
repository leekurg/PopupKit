//
//  CoverTest.swift
//  PopupKitExample
//
//  Created by Илья Аникин on 25.08.2024.
//

import PopupKit
import SwiftUI
import PopupKit

struct CoverTest: View {
    @State private var c1 = false
    @State private var c2 = false
    @State private var c3 = false
    @State private var c4 = false
    @State private var cNavigation = false
    @State private var ci: MyIdent?
    
    @EnvironmentObject var presenter: CoverPresenter
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mint
                
                VStack {
                    Button("Non-modal material cover") {
                        c1.toggle()
                    }
                    
                    Button("Modal interactive cover") {
                        c2.toggle()
                    }
                    
                    Button("Modal non-interactive cover") {
                        c3.toggle()
                    }
                    
                    Button("Modal interactive too high cover") {
                        c4.toggle()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .ignoresSafeArea()
            .navigationTitle("Cover")
        }
        .cover(
            isPresented: $c1,
            background: .ultraThinMaterial,
            modal: .none,
            cornerRadius: 0
        ) {
            VStack {
                Text("Root view is interactive!")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue)
                    .padding()
                
                Button("Open another one") {
                    presenter.present(
                        id: UUID(),
                        modal: .none,
                        background: .ultraThinMaterial
                    ) {
                        Text("Nicely stacked!")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.blue)
                            .frame(height: 400)
                            .padding()
                    }
                }
                .buttonStyle(.bordered)
            }
            .frame(height: 400)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .topLeading) {
                Text("Respects content size")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.white)
            }
            .border(.white)
            .padding()
        }
        .cover(isPresented: $c2, modal: .modal(interactivity: .interactive)) {
            VStack {
                Text("Tap on root view is closing the cover!")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            .frame(minHeight: 400)
        }
        .cover(
            isPresented: $c3,
            background: .brown,
            modal: .modal(interactivity: .noninteractive),
            cornerRadius: 30
        ) {
            VStack {
                Text("Doesn't allows to scroll down or tap on root view")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            .frame(maxWidth: .infinity, minHeight: 600)
            .overlay(alignment: .topTrailing) {
                Button {
                    presenter.popLast()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .padding(10)
                        .background(.white.opacity(0.2), in: Circle())
                        .foregroundStyle(.gray)
                }
                .padding()
            }
        }
        .cover(
            isPresented: $c4,
            background: .ultraThinMaterial,
            modal: .modal(interactivity: .interactive)
        ) {
            VStack(spacing: 0) {
                Color.cyan.frame(height: 300).overlay { Text("300x300") }
                Color.blue.frame(height: 300).overlay { Text("300x300") }
                Color.indigo.frame(height: 300).overlay { Text("300x300") }
                Color.green.frame(height: 300).overlay { Text("300x300") }
            }
            .frame(width: 300)
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
        }
        .cover(
            item: $ci,
            background: .blue,
            modal: .modal(interactivity: .interactive)
        ) { item in
            Text("Item sheet with value \(item.value)")
                .foregroundStyle(.white)
                .font(.system(.title, design: .rounded, weight: .bold))
                .frame(height: 500)
        }
        .cover(
            isPresented: $cNavigation,
            background: .indigo,
            modal: .none
        ) {
            NavigationView {
                Button("Button") {
                    print("Tapped")
                }
                .navigationTitle("Title")
            }
        }
    }
}

extension CoverTest {
    struct MyIdent: Identifiable {
        let id: UUID
        let value: Int
    }
}

#Preview {
    CoverTest()
        .previewPopupKit(.cover(ignoredSafeAreaEdges: .all))
}
