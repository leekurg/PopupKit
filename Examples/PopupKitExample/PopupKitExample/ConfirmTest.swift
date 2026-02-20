//
//  ConfirmTest.swift
//  PopupKitExample
//
//  Created by Илья Аникин on 02.10.2024.
//

import PopupKit
import SwiftUI

struct ConfirmTest: View {
    @State var c1: Bool = false
    @State var cItem: MyIdent?
    @State var cs: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0, green: 0.7, blue: 0.3)

                VStack {
                    Button("Customizable actions") {
                        c1.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .ignoresSafeArea()
            .navigationTitle("Confirmation dialog")
        }
        .confirm(isPresented: $c1) {
            VStack(spacing: 20) {
                VStack(spacing: 30) {
                    ExpandableHeader()
                }
            }
        } actions: {
            Regular(
                text: Text("Action"),
                action: {}
            )
            Regular(
                text: Text("Action with icon"),
                image: .systemName("sparkles"),
                action: {}
            )
            Destructive(
                text: Text("Destructive action"),
                action: {}
            )
            Cancel(text: Text("My cancel 1"))
            Cancel(text: Text("My cancel 2"))
            Regular(
                text: Text("Thin small-sized text action")
                    .font(.system(size: 10, weight: .thin))
                    .foregroundStyle(.black),
                action: {}
            )
            Regular(
                text: Text("Big bold colored text action")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.indigo),
                action: {}
            )
        }
        .confirm(item: $cItem) {
            Regular(text: Text("Action 1"), action: {})
        }
        .confirmationDialog("Title", isPresented: $cs) {
            Button("Action 1") {}

            Button("Action 2") {}

            Button("Action 3") {}
        }
        .popupActionTint(.blue)
        .popupActionFonts(
            regular: .system(size: 18, weight: .regular),
            cancel: .system(size: 18, weight: .semibold)
        )
    }
}

fileprivate struct ExpandableHeader: View {
    @State var expanded = false
    @State var isText2 = false

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.brown)
            .frame(height: expanded ? .infinity : 100)
            .overlay {
                VStack {
                    Text("Place any content you like!")
                        .foregroundStyle(.white)
                        .font(.system(size: 15, weight: .regular, design: .monospaced))

                    if isText2 {
                        Text("Even interactive!")
                            .foregroundStyle(.white)
                            .font(.system(size: 15, weight: .regular, design: .monospaced))
                    }

                    Button("Interact") {
                        withAnimation(.spring) {
                            expanded.toggle()

                            if expanded {
                                withAnimation(.spring.delay(1)) {
                                    isText2 = true
                                }
                            } else {
                                isText2 = false
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
    }
}

extension ConfirmTest {
    struct MyIdent: Identifiable {
        let id: UUID
        let value: Int
    }
}

#Preview {
    ConfirmTest()
        .previewPopupKit(.confirm)
        .popupActionTint(.blue)
        .popupActionFonts(
            regular: .system(size: 18, weight: .regular),
            cancel: .system(size: 18, weight: .semibold)
        )
}
