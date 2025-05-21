//
//  AppDelegate.swift
//  TestOpenMeteo
//
//  Created by user on 21.05.2025.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.systemGroupedBackground]
        return true
    }
}

