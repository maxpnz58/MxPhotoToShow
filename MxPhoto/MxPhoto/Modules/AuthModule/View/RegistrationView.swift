//
//  RegistrationView.swift
//  MxPhoto
//
//  Created by Max on 21.04.2025.
//

import SwiftUI
import GoogleSignInSwift

struct RegistrationView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: AuthField?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 12) {
                        Image(systemName: "person.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 8) {
                            Text("Создайте аккаунт")
                                .font(.title2.bold())
                            
                            Text("Зарегистрируйтесь чтобы получить доступ ко всем возможностям")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        // Email Field
                        AuthTextField(
                            title: "Email",
                            placeholder: "example@mail.com",
                            text: $viewModel.inputEmail,
                            focusedField: $focusedField,
                            fieldType: .email,
                            contentType: .emailAddress,
                            validation: viewModel.isEmailValid
                        )
                        
                        // Password Field
                        AuthSecureField(
                            title: "Пароль",
                            placeholder: "Не менее 8 символов",
                            text: $viewModel.inputPassword,
                            focusedField: $focusedField,
                            fieldType: .password,
                            validation: viewModel.isPasswordValid
                        )
                        
                        // Confirm Password Field
                        AuthSecureField(
                            title: "Подтвердите пароль",
                            placeholder: "Повторите пароль",
                            text: $viewModel.confirmPassword,
                            focusedField: $focusedField,
                            fieldType: .confirmPassword,
                            validation: viewModel.isPasswordValid
                        )
                    }
                    
                    // Validation Errors
                    if let error = viewModel.errorMessage {
                        ValidationErrorView(error: error)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    // Register Button
                    Button(action: viewModel.register) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Зарегистрироваться")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isRegistrationValid ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!viewModel.isRegistrationValid || viewModel.isLoading)
                    
                    // Social Auth Section
//                    VStack(spacing: 16) {
//                        DividerWithText(label: "Или продолжите с")
//                        
//                        GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .wide)) {
//                            viewModel.signInWithGoogle()
//                        }
//                        .frame(height: 44)
//                    }
                }
                .padding()
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .alert("Регистрация успешна", isPresented: $viewModel.isAuthenticated) {
                Button("OK", role: .cancel) { dismiss() }
            } message: {
                Text("Добро пожаловать, \(viewModel.inputEmail)!")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.errorMessage)
            .onChange(of: viewModel.inputPassword) { _ , _ in viewModel.validatePasswords() }
            .onChange(of: viewModel.confirmPassword) { _ , _ in viewModel.validatePasswords() }
        }
    }
}

// MARK: - Custom Components

enum AuthField {
    case email, password, confirmPassword
}

struct AuthTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    @FocusState.Binding var focusedField: AuthField?
    let fieldType: AuthField
    let contentType: UITextContentType
    let validation: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .focused($focusedField, equals: fieldType)
                .textContentType(contentType)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            focusedField == fieldType ? Color.blue : Color.gray.opacity(0.3),
                            lineWidth: 1.5
                        )
                )
                .overlay(alignment: .trailing) {
                    if validation && !text.isEmpty {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .padding(.trailing)
                    }
                }
        }
    }
}

struct AuthSecureField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    @FocusState.Binding var focusedField: AuthField?
    let fieldType: AuthField
    let validation: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            SecureField(placeholder, text: $text)
                .focused($focusedField, equals: fieldType)
                .textContentType(.newPassword)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            focusedField == fieldType ? Color.blue : Color.gray.opacity(0.3),
                            lineWidth: 1.5
                        )
                )
                .overlay(alignment: .trailing) {
                    if validation && !text.isEmpty {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .padding(.trailing)
                    }
                }
        }
    }
}

struct DividerWithText: View {
    let label: String
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
        }
    }
}

struct ValidationErrorView: View {
    let error: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            
            Text(error)
                .foregroundColor(.red)
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}
