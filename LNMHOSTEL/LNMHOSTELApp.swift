//
//  LNMHOSTELApp.swift
//  LNMHOSTEL
//
//  Created by kavya khandelwal  on 19/05/25.
//

import SwiftUI
import UIKit
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
    
    @available(iOS 9.0,*)
    func application(_ application: UIApplication,open url: URL , options:[UIApplication.OpenURLOptionsKey:Any] = [:])->Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct LNMHOSTELApp: App {
    
    // register app delegate for Firebase setup
      @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
