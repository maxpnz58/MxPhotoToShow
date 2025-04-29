//
//  MxPhotoApp.swift
//  MxPhoto
//
//  Created by Max on 21.04.2025.
//

import SwiftUI
import FirebaseCore

@main
struct YourApp: App {
    
     let debugS = false
    
    @StateObject private var authViewModel = AuthViewModel()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


  var body: some Scene {
    WindowGroup {
        
        if !debugS {
            if authViewModel.isAuthenticated {
                PhotoGridView()
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        } else {
            PhotoGridView()
        }
    }
  }
}


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

