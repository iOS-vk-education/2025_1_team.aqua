//
//  AuthView.swift
//  Purely
//
//  Created by Dmitrii Eselidze on 27.11.2025.
//


import SwiftUI
import Combine // реактивное программирование

final class UserStorage: ObservableObject {
    var name: String = ""
    var isLoggedIn: Bool = false
    var userToken: String = ""
}

struct AuthView: View {
    @State var name: String = ""
    @State var password: String = ""
    @State var isMainTabPresented = false
    @State var isTipPresented = false
    @StateObject var userStorage = UserStorage()

    var body: some View {
        VStack(spacing: 16) {
            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)

            TextField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            Button {
                isMainTabPresented = true
                userStorage.name = name
            } label: {
                Text("Login in")
                    .padding()
                    .background(.purple)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                    .font(.headline)
            }
            .popover(isPresented: $isTipPresented) {
                Button {
                    // isTipPresented = false
                    print("TIP TAPPED")
                } label: {
                    Text("Some help")
                }
                .padding()
                .buttonStyle(.plain)
                .presentationCompactAdaptation(.popover)
                .onDisappear {
                    print("Tap")
                }
            }
            .onAppear {
                isTipPresented = true
            }
        }
        .padding()
//        .fullScreenCover(isPresented: $isMainTabPresented) {
////            MainTabBarController()
////                .environmentObject(userStorage)
//        }
        .navigationTitle("Auth")
    }
}

#Preview {
    AuthView()
}
