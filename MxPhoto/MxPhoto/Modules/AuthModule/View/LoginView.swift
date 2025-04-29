//
//  LoginView.swift
//  MxPhoto
//
//  Created by Max on 21.04.2025.
//

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @State private var showRegistration = false
    @State private var showForgotPassword = false
    
    @EnvironmentObject private var viewModel: AuthViewModel
    @FocusState private var focusedField: AuthField?
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isAuthenticated {
                    WelcomeView()
                } else {
                    authContent
                }
            }
            .animation(.easeInOut, value: viewModel.isAuthenticated)
        }
    }
    
    private var authContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                inputFields
                actionsSection
                socialAuthSection
            }
            .padding()
            .padding(.top, 50)
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .sheet(isPresented: $showForgotPassword) { ForgotPasswordView() }
        .sheet(isPresented: $showRegistration) { RegistrationView() }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue)
            
            Text("Добро пожаловать!")
                .font(.title2.bold())
        }
    }
    
    private var inputFields: some View {
        VStack(spacing: 16) {
            AuthTextField(
                title: "Email",
                placeholder: "example@mail.com",
                text: $viewModel.inputEmail,
                focusedField: $focusedField,
                fieldType: .email,
                contentType: .emailAddress,
                validation: viewModel.isEmailValid
            )
            
            AuthSecureField(
                title: "Пароль",
                placeholder: "Введите пароль",
                text: $viewModel.inputPassword,
                focusedField: $focusedField,
                fieldType: .password,
                validation: viewModel.isPasswordValid
            )
            
            if let error = viewModel.errorMessage {
                ValidationErrorView(error: error)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 16) {
            Button(action: viewModel.login) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Войти")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(15)
                .background(viewModel.isLoginValid ? Color.blue : Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!viewModel.isLoginValid || viewModel.isLoading)
            
            HStack {
                Spacer()
                
                Button {
                    showForgotPassword.toggle()
                } label: {
                    Text("Забыли пароль?")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(.blue))
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button {
                    showRegistration.toggle()
                } label: {
                    Text("Регистрация")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(.blue))
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }
    
    private var socialAuthSection: some View {
        VStack(spacing: 16) {
            DividerWithText(label: "Или войдите с помощью")
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark , style: .standard)) {
                
            }
            .frame(height: 44)
        }
    }
}
