//
//   WelcomeView.swift
//  MxPhoto
//
//  Created by Max on 21.04.2025.
//

import SwiftUI


struct WelcomeView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Text("Добро пожаловать! 🎉")
                .font(.largeTitle.bold())
            
            
            if let user = authViewModel.currentUser {
                Text("Ваш Email: \(user.email ?? "не знаем")")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Text("Не удалось загрузить данные")
                    .foregroundColor(.red)
            }

            Button("Выйти") {
                authViewModel.logout()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}
