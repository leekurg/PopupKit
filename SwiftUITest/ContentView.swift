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
//        OverlayTest()
        NotificationTest()
//        ScrollAwayTest()
    }
}

struct ScrollAwayTest: View {
    @GestureState private var dragState: CGFloat
    @State var isShow = true
    @State var isThreshold = false
    
    init() {
        self._dragState = GestureState(
            initialValue: .zero,
            resetTransaction: .init(animation: .bouncy)
        )
    }
    
    var body: some View {
        ZStack {
            if isShow {
                RoundedRectangle(cornerRadius: 25)
                    .fill(.orange)
                    .frame(width: 300, height: 130)
                    .padding(.bottom, 100)
                    .offset(y: dragState)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .updating($dragState) { value, state, _ in
                                withAnimation(.spring) {
                                    state = value.translation.height > 0 ? value.translation.height : value.translation.height / 3
                                }
                            }
                            .onChanged { gestureValue in
//                                print("\(gestureValue.velocity.height)")
                                if isShow, gestureValue.predictedEndTranslation.height > 300 {
                                    withAnimation(.spring) { isShow.toggle() }
                                }
                            }
                    )
                    .transition(.move(edge: .bottom))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

struct NotificationTest: View {
    @Environment(\.notificationTransitionAnimation) var transitionAnimation
    
    @State var path = NavigationPath()
    @State var notificationPresenter = NotificationPresenter(verbose: true)
    @State var isFullscreen = false
    @State var isSheet = false
    
    @State var n1 = false
    @State var n2 = false
    @State var n3 = false
    @State var n4 = false
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                Button("Continuous notification 1") {
                    n1.toggle()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Show notification 2") {
                    n2.toggle()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Show notification 3") {
                    n3.toggle()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Show notification 4") {
                    n4.toggle()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Pop to root") {
                    withAnimation(transitionAnimation.removal) {
                        notificationPresenter.popToRoot()
                    }
                }
                .buttonStyle(.bordered)
                
                Button {
                    n1.toggle()
                    n2.toggle()
                    n3.toggle()
                    n4.toggle()
                } label: {
                    Text("SHOW ALL")
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .padding()
                        .background(.blue, in: Capsule())
                }
                
                Button {
                    path.append(DestinationA())
                } label: {
                    Text("Push to A")
                        .padding(10)
                        .background(.orange, in: Capsule())
                }
                
                Button {
                    isFullscreen.toggle()
                } label: {
                    Text("Fullscreen to B")
                        .padding(10)
                        .background(.orange, in: Capsule())
                }
                
                Button {
                    isSheet.toggle()
                } label: {
                    Text("Sheet to B")
                        .padding(10)
                        .background(.orange, in: Capsule())
                }
                
                Button {
                    for entry in notificationPresenter.stack {
                        print("[\(entry.deep)]: \(entry.id)")
                    }
                } label: {
                    Text("Reveal stack")
                        .foregroundStyle(.white)
                        .padding(15)
                        .frame(maxWidth: .infinity)
                        .background(.indigo, in: RoundedRectangle(cornerRadius: 25))
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.bottom, 100)
                
                Color.red.frame(height: 30)
                Color.indigo.frame(height: 30)
                Color.yellow.frame(height: 30)
            }
            .navigationTitle("Title")
            .navigationDestination(for: DestinationA.self) { _ in
                NotificationViewA()
            }
            .fullScreenCover(isPresented: $isFullscreen) {
                NotificationViewB(isPresented: $isFullscreen)
            }
            .sheet(isPresented: $isSheet) {
                NotificationViewB(isPresented: $isSheet)
            }
            .notification(isPresented: $n1, expiration: .never) {
                Text("Continuous notification 1")
            }
            .notification(isPresented: $n2) {
                Text("Notification 2")
            }
            .notification(isPresented: $n3) {
                Text("Notification 3")
            }
            .notification(isPresented: $n4) {
                Text("Notification 4")
            }
        }
        .notificationRoot(
            alignment: .bottom
        )
        .environment(notificationPresenter)
    }
    
    struct DestinationA: Hashable { }
}

struct NotificationViewA: View {
    @State private var isNotified = false
    
    var body: some View {
        VStack {
            Text("NotificationViewA")
            
            Button("Show notification") {
                isNotified.toggle()
            }
            .buttonStyle(.borderedProminent)
        }
        .notification(isPresented: $isNotified) {
            HStack {
                Image(systemName: "star.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .foregroundStyle(.mint)
                    .padding()
                
                Text("Nested notification")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct NotificationViewB: View {
    @Environment(NotificationPresenter.self) var presenter
    @State private var isNotified = false
    
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Text("NotificationViewB")
            
            Button("Show notification") {
                isNotified.toggle()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Close") {
                isPresented = false
            }
            .buttonStyle(.bordered)
        }
        .notification(isPresented: $isNotified) {
            HStack {
                Image(systemName: "star")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .foregroundStyle(.mint)
                    .padding()
                
                Text("Fullscreen notification")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
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
            .fullscreenOverlay(isPresented: $isShow) {
                SearchView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .border(.red)
        .fullscreenOverlayRoot(.move(edge: .bottom))
        .environment(overlayPresenter)
    }
}

struct SearchView: View {
    var body: some View {
//        NavigationStack {
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
//            .navigationTitle("Title")
//            .navigationBarTitleDisplayMode(.inline)
//        }
    }
}

#Preview {
    ContentView()
}
