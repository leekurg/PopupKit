//
//  PopupTest.swift
//  PopupKitExample
//
//  Created by Илья Аникин on 17.10.2024.
//

import PopupKit
import SwiftUI

// stacked popup - with dismissing on outside tap

// text input popup - text input on the main screen

// fullscreen popup - respecting safe area

// alert with custom actions - actions with - rich - customization

struct PopupTest: View {
    @State private var stacked1 = false
    @State private var textInput = false
    @State private var fullscreen = false
    @State private var alert = false
    @State private var alertWithContent = false
    
    @State private var text = ""
    
    @EnvironmentObject private var presenter: PopupPresenter

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.76, green: 0.45, blue: 1)
                
                VStack {
                    Button("Stacked") {
                        stacked1.toggle()
                    }
                    
                    HStack {
                        Button("For text input") {
                            textInput.toggle()
                        }
                        
                        if !text.isEmpty {
                            Text(": \(text)")
                        }
                    }
                    
                    Button("Large") {
                        fullscreen.toggle()
                    }
                    
                    Divider()
                    
                    Group {
                        Button("Alert") {
                            alert.toggle()
                        }
                        
                        Button("Alert with user content") {
                            alertWithContent.toggle()
                        }
                    }
                    .tint(.orange)
                }
                .buttonStyle(.borderedProminent)
                .navigationTitle("Popup & alert")
            }
            .ignoresSafeArea()
        }
        .popup(isPresented: $stacked1) {
            PopupCongrats()
        }
        .popup(isPresented: $textInput, outTapBehavior: .dismiss) {
            PopupText(text: $text)
        }
        .popup(isPresented: $fullscreen) {
            PopupLarge()
        }
        .popupAlert(
            isPresented: $alert,
            title: "Present an alert🌞!",
            msg: "Style actions and present alert in stack!"
        ) {
            Regular(
                text: Text("Action with icon"),
                image: .systemName("sparkles"),
                action: {}
            )
            Destructive(
                text: Text("Destructive action"),
                action: {}
            )
            Regular(
                text: Text("Rich")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.indigo)
                ,
                action: {}
            )
            Regular(
                text: Text("Action's")
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.cyan)
                ,
                action: {}
            )
            Regular(
                text: Text("Customization")
                    .font(.system(size: 15, weight: .thin, design: .monospaced))
                    .foregroundStyle(.mint)
                ,
                action: {}
            )
        }
        .popupAlert(isPresented: $alertWithContent) {
            PopupCustom()
                .padding(.vertical, 20)
        } actions: {
            Regular(
                text: Text("Wow").foregroundStyle(.purple),
                action: {}
            )
        }

    }
}

struct PopupCongrats: View {
    @State var animatedColor = false
    @State var animatedScale = false
    @State var popup = false

    @EnvironmentObject var presenter: PopupPresenter
    
    var body: some View {
        VStack {
            Image(systemName: "hands.sparkles.fill")
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundStyle(animatedColor ? .red : .orange)
                .rotationEffect(.degrees(animatedScale ? 360 : 0))
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 0.5).repeatForever(autoreverses: true)
                    ) {
                        animatedColor.toggle()
                    }

                    withAnimation(
                        .spring(duration: 1)
                        .delay(0.2)
                        .repeatForever(autoreverses: true)
                    ) {
                        animatedScale.toggle()
                    }
                }
            
            Text("Fully customizable popups!")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
            
            Button("Stack another one!") {
                popup.toggle()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 10)

            Button("Close") {
                presenter.popLast()
            }
        }
        .padding([.horizontal, .top], 30)
        .padding(.bottom, 20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25))
        .tint(.purple)
        .popup(isPresented: $popup) {
            PopupStacked()
        }
    }
}

struct PopupStacked: View {
    @EnvironmentObject var presenter: PopupPresenter
    
    var body: some View {
        ZStack {
            Color.green
            Color.black.opacity(0.15)
            
            VStack {
                Text("Stack")
                Text("as much")
                Text("as")

                Text("you like!")
                    .foregroundStyle(.yellow)
            }
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .padding(.bottom, 30)
            .foregroundStyle(.white)
            
            Button("Close") {
                presenter.popLast()
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom)
            .tint(.purple)
        }
        .frame(width: 250, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}

struct PopupText: View {
    @Binding var text: String

    @EnvironmentObject var presenter: PopupPresenter

    var body: some View {
        VStack {
            Text("Get text input from the user!")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(20)

            TextField("", text: $text, axis: .horizontal)
                .padding()
                .background(.ultraThinMaterial, in: Capsule())
                .padding()

            Button("Done") {
                presenter.popLast()
            }
            .tint(.purple)
        }
        .frame(width: 300, height: 250)
        .background(.mint, in: RoundedRectangle(cornerRadius: 25))
    }
}

struct PopupLarge: View {
    @EnvironmentObject var presenter: PopupPresenter

    let red = Color(red: 0.7, green: 0.2, blue: 0.2)

    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)
            .overlay {
                VStack {
                    Text("Screen-wide popup!")
                        .font(.system(size: 27, weight: .bold, design: .rounded))
                        .padding(.bottom, 10)

                    Text("respecting").foregroundStyle(Color(red: 0.3, green: 0.3, blue: 1))
                    Text("or").foregroundStyle(.secondary)
                    Text("ignoring").foregroundStyle(red)
                    Text("the safe area").foregroundStyle(.secondary)

                    Text("and paddings").foregroundStyle(.secondary)
                }
                .font(.system(size: 23, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)

            }
            .foregroundStyle(.black)
            .overlay(alignment: .topTrailing) {
                CloseButton {
                    presenter.popLast()
                }
                .padding()
            }
            .overlay(alignment: .top) {
                Text("respects safe area")
                    .font(.system(.caption, design: .monospaced))
            }
            .overlay(alignment: .bottom) {
                Text("respects safe area")
                    .font(.system(.caption, design: .monospaced))
            }
            .overlay(alignment: .trailing) {
                Text("padding 20.0")
                    .font(.system(.caption, design: .monospaced))
                    .fixedSize()
                    .rotationEffect(.degrees(90))
                    .frame(width: 20)
            }
            .overlay(alignment: .leading) {
                Text("padding 20.0")
                    .font(.system(.caption, design: .monospaced))
                    .fixedSize()
                    .rotationEffect(.degrees(-90))
                    .frame(width: 20)
            }
            .foregroundStyle(Color(red: 0.3, green: 0.3, blue: 1))
            .padding(.horizontal)
    }
}

struct PopupCustom: View {
    @State private var rolling = false
    @State private var scaling = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Custom dynamically-sized header!")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)

            HStack(spacing: 30) {
                square

                Button("Scale") {
                    withAnimation(.spring) {
                        scaling.toggle()
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .tint(.purple)
        .frame(width: 300)
    }

    var square: some View {
        RoundedRectangle(cornerRadius: rolling ? 25 : 10)
            .fill(rolling ? .orange : .mint)
            .frame(width: scaling ? 50 * 2 : 50, height: scaling ? 50 * 2 : 50)
            .rotationEffect(.degrees(rolling ? 720 : 0))
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    rolling.toggle()
                }
            }
    }
}

struct AnimatedSquare: View {
    @State private var animated = false

    var body: some View {
        RoundedRectangle(cornerRadius: animated ? 25 : 10)
            .fill(animated ? .orange : .purple)
            .frame(width: 50, height: 50)
            .rotationEffect(.degrees(animated ? 720 : 0))
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    animated.toggle()
                }
            }
    }
}

#Preview {
    PopupTest()
        .previewPopupKit(.popup(ignoredSafeAreaEdges: []))
//        .preferredColorScheme(.dark)
        .environment(\.popupActionTint, .blue)
}
