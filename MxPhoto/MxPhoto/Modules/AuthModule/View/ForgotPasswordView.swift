//
//  ForgotPasswordView.swift
//  MxPhoto
//
//  Created by Max on 21.04.2025.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ForgotPasswordViewModel()
    @FocusState private var isEmailFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "key.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 8) {
                            Text("Забыли пароль?")
                                .font(.title2.bold())
                            
                            Text("Введите email, связанный с вашим аккаунтом, и мы отправим инструкции для сброса пароля")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("example@mail.com", text: $viewModel.email)
                            .focused($isEmailFieldFocused)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        isEmailFieldFocused ? Color.blue : Color.gray.opacity(0.3),
                                        lineWidth: 1.5
                                    )
                            )
                            .overlay(alignment: .trailing) {
                                if viewModel.isValidEmail && !viewModel.email.isEmpty {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .padding(.trailing)
                                }
                            }
                    }
                    
                    // Error Message
                    if let error = viewModel.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    // Submit Button
                    Button(action: viewModel.resetPassword) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Отправить инструкции")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            viewModel.isEmailValid ? Color.blue : Color.gray.opacity(0.3)
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!viewModel.isEmailValid || viewModel.isLoading)
                }
                .padding()
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .alert("Письмо отправлено", isPresented: $viewModel.isSuccess) {
                Button("OK", role: .cancel) { dismiss() }
            } message: {
                VStack {
                    Image(systemName: "envelope.open.fill")
                        .foregroundColor(.blue)
                        .padding(.bottom, 8)
                    
                    Text("Инструкции по восстановлению пароля отправлены на \(viewModel.email)")
                        .font(.subheadline)
                }
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
            .onChange(of: viewModel.email) { _ , _ in
                viewModel.validateEmail()
            }
        }
    }
}
