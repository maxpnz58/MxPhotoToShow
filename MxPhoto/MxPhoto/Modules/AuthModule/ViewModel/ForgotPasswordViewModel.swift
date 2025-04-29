//
//  ForgotPasswordViewModel.swift
//  MxPhoto
//
//  Created by Max on 21.04.2025.
//

import Combine
import FirebaseAuth

class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var isValidEmail = false
    
    var isEmailValid: Bool {
        !email.isEmpty && isValidEmail
    }
    
    func validateEmail() {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        isValidEmail = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    func resetPassword() {
        guard isEmailValid else { return }
        
        isLoading = true
        errorMessage = nil
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.isSuccess = true
                }
            }
        }
    }
}
