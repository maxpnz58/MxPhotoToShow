//
//  AuthViewModel.swift
//  MxPhoto
//
//  Created by Max on 21.04.2025.
//

import Combine
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

final class AuthViewModel: ObservableObject {
    // MARK: - Existing Properties
    @Published var inputEmail = ""
    @Published var inputPassword = ""
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var currentUser: User?
    
    // MARK: - New Registration Properties
    @Published var confirmPassword = ""
    @Published var isEmailValid = false
    @Published var isPasswordValid = false
    @Published var isConfirmValid = false
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let authKey = "authCredentials"
    
    // MARK: - Computed Properties
    var isRegistrationValid: Bool {
        isEmailValid && isPasswordValid && isConfirmValid
    }
    
    init() {
        print("AuthViewModel инициализирован")
        checkSavedAuth()
        setupBindings()
    }
    
   private enum FieldType {
        case email, password
    }
    
    var isLoginValid: Bool {
        !inputEmail.isEmpty && !inputPassword.isEmpty && isEmailValid
    }
    
    func validateLoginFields() {
        validateEmail()
        isPasswordValid = !inputPassword.isEmpty
    }
    
    // MARK: - Setup Bindings
    private func setupBindings() {
        $isAuthenticated
            .sink { [weak self] isAuth in
                isAuth ? self?.saveAuthData() : self?.clearAuthData()
            }
            .store(in: &cancellables)
        
        $inputEmail
            .dropFirst()
            .sink { [weak self] _ in self?.validateEmail() }
            .store(in: &cancellables)
        
        Publishers.CombineLatest($inputPassword, $confirmPassword)
            .dropFirst()
            .sink { [weak self] _ in self?.validatePasswords() }
            .store(in: &cancellables)
    }
    
    // MARK: - Validation Logic
    private func validateEmail() {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        isEmailValid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: inputEmail)
    }
    
    func validatePasswords() {
        isPasswordValid = inputPassword.count >= 8
        isConfirmValid = inputPassword == confirmPassword && !confirmPassword.isEmpty
    }
    
    // MARK: - Existing Auth Methods
    func login() {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: inputEmail, password: inputPassword) { [weak self] result, error in
            self?.handleAuthResult(result: result, error: error)
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            resetAuthState()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func register() {
        guard isRegistrationValid else {
            errorMessage = "Пожалуйста, заполните все поля корректно"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: inputEmail, password: inputPassword) { [weak self] result, error in
            self?.handleAuthResult(result: result, error: error)
        }
    }
    
//    // MARK: - Google Sign-In
//    func signInWithGoogle() {
//        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
//        
//        let config = GIDConfiguration(clientID: clientID)
//        GIDSignIn.sharedInstance.configuration = config
//        
//        GIDSignIn.sharedInstance.signIn(withPresenting: UIApplication.shared.rootViewController ?? UIViewController()) { [weak self] result, error in
//            if let error = error {
//                self?.errorMessage = error.localizedDescription
//                return
//            }
//            
//            guard let user = result?.user,
//                  let idToken = user.idToken?.tokenString else {
//                self?.errorMessage = "Ошибка аутентификации"
//                return
//            }
//            
//            let credential = GoogleAuthProvider.credential(
//                withIDToken: idToken,
//                accessToken: user.accessToken.tokenString
//            )
//            
//            Auth.auth().signIn(with: credential) { [weak self] result, error in
//                self?.handleAuthResult(result: result, error: error)
//            }
//        }
//    }
//    
    // MARK: - Helpers
    private func handleAuthResult(result: AuthDataResult?, error: Error?) {
        DispatchQueue.main.async {
            self.isLoading = false
            if let user = result?.user {
                self.currentUser = User(uid: user.uid, email: user.email ?? "unknown")
                self.isAuthenticated = true
                self.clearPasswords()
            } else if let error = error {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func resetAuthState() {
        inputEmail = ""
        inputPassword = ""
        confirmPassword = ""
        isAuthenticated = false
        currentUser = nil
    }
    
    private func clearPasswords() {
        inputPassword = ""
        confirmPassword = ""
    }
    
    // MARK: - UserDefaults Methods
    private func saveAuthData() {
        guard let user = currentUser else { return }
        let authData: [String: Any] = [
            "uid": user.uid,
            "email": user.email ?? "unknown",
            "isAuthenticated": true
        ]
        userDefaults.set(authData, forKey: authKey)
    }
    
    private func clearAuthData() {
        userDefaults.removeObject(forKey: authKey)
    }
    
    func checkSavedAuth() {
        print("Проверка сохраненных данных аутентификации...") // Логирование
        
        guard let authData = userDefaults.dictionary(forKey: authKey),
              let isAuthenticated = authData["isAuthenticated"] as? Bool,
              isAuthenticated,
              let uid = authData["uid"] as? String,
              let email = authData["email"] as? String else {
            print("Сохраненные данные не найдены")
            return
        }
        
        print("Найдены сохраненные данные: \(email)")
        self.currentUser = User(uid: uid, email: email)
        self.isAuthenticated = true
    }
    
    private func autoLogin() {
            print("Попытка автоматического входа...")
            
        guard (currentUser?.email) != nil else {
                print("Ошибка: email не найден")
                return
            }

            isLoading = true
            
            Auth.auth().signIn(withEmail: "kuzma-2000@mail.ru", password: "maxpnz") { [weak self] _, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        print("Ошибка автоматического входа: \(error.localizedDescription)")
                        self?.errorMessage = error.localizedDescription
                        self?.isAuthenticated = false
                        self?.clearAuthData()
                    } else {
                        print("Автоматический вход успешен")
                        self?.isAuthenticated = true
                    }
                }
            }
        }
}


extension UIApplication {
    var rootViewController: UIViewController? {
        guard let windowScene = connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }
        return rootVC
    }
}
