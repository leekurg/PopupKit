//
//  NotificationTest.swift
//  PopupKitExample
//
//  Created by Илья Аникин on 23.08.2024.
//

import PopupKit
import SwiftUI

struct NotificationTest: View {
    @EnvironmentObject var presenter: NotificationPresenter
    
    @State var isSheet = false
    @State var count = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.orange.opacity(0.7)
                
                VStack {
                    Button {
                        count += 1

                        presenter.present(
                            id: UUID(),
                            expiration: count < 3 ? .timeout(.seconds(1)) : .never
                        ) {
                            Text(
                                count < 3
                                    ? "Expired in 1 second"
                                    : "Continious notification"
                            )
                                .frame(maxWidth: .infinity, minHeight: 100)
                                .background {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(.thinMaterial)
                                        .overlay {
                                            ContainerRelativeShape()
                                                .stroke(.blue, lineWidth: 0.5)
                                                .padding(5)
                                        }
                                }
                                .containerShape(RoundedRectangle(cornerRadius: 30))
                                .padding(.horizontal)
                        }
                    } label: {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding(10)
                            .background(.white.opacity(0.2), in: Circle())
                            .foregroundStyle(.blue)
                    }
                    .padding()
                    
                    Button("Open sheet") {
                        isSheet.toggle()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .ignoresSafeArea()
            .navigationTitle("Notification")
            .sheet(isPresented: $isSheet) {
                NavigationStack {
                    Button {
                        presenter.present(
                            id: UUID(),
                            expiration: .never
                        ) {
                            HStack(spacing: 40) {
                                Image(systemName: "sparkles")
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(width: 120, height: 120)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.purple)
                                
                                Text("Still on top!")
                                    .foregroundStyle(.green)
                                    .font(.system(.title2, design: .rounded, weight: .bold))
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(.thinMaterial)
                            }
                            .padding(.horizontal)
                        }
                    } label: {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding(10)
                            .background(.black.opacity(0.1), in: Circle())
                            .foregroundStyle(.blue)
                    }
                    .padding()
                    .navigationTitle("System sheet")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}

struct AnimatedNotificationView: View {
    let animationKind: AnimationKind
    @State var isAnimating: Bool = false

    var body: some View {
        HStack {
            image
                .font(.system(size: 25, weight: .bold))
                .foregroundStyle(.purple)
                .contentTransition(.symbolEffect(.replace))
            
            Text("Hidden items")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
        }
        .frame(height: 50)
        .padding(.horizontal, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .compositingGroup()
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .onAppear {
            Task {
                try? await Task.sleep(for: .seconds(0.5))
                withAnimation(.easeInOut(duration: 0.5)) {
                    isAnimating.toggle()
                }
            }
        }
    }
    
    var image: some View {
        switch animationKind {
        case .hide:
            Image(systemName: isAnimating ? "eye" : "eye.slash")
        case .unhide:
            Image(systemName: isAnimating ? "eye.slash" : "eye")
        }
    }
    
    enum AnimationKind {
        case hide, unhide
    }
}

#Preview {
    NotificationTest()
        .previewPopupKit(.notification)
//        .preferredColorScheme(.dark)
}
