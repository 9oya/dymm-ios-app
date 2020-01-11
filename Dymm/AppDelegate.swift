//
//  AppDelegate.swift
//  Dymm
//
//  Created by eunsang lee on 06/08/2019.
//  Copyright © 2019 9oya. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var gParams: Parameters?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame:UIScreen.main.bounds)
//        window?.rootViewController = UINavigationController(rootViewController: HomeViewController())
        window?.rootViewController = UINavigationController(rootViewController: DiaryViewController())
        window?.makeKeyAndVisible()
        setNavigationBar()
        
        // Facebook login
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Google sign in
        GIDSignIn.sharedInstance().clientID = "613886633009-su0n757hc1qk6aefi84qfcc2imv78012.apps.googleusercontent.com"
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate {
    
    // MARK: Private Methods
    
    private func setNavigationBar() {
        let navigationBarAppearance = UINavigationBar.appearance()
//        navigationBarAppearance.tintColor = UIColor.black
//        navigationBarAppearance.barTintColor = UIColor.white
        navigationBarAppearance.backIndicatorImage = .itemArrowLeft
        navigationBarAppearance.backIndicatorTransitionMaskImage = .itemArrowLeft
        navigationBarAppearance.shadowImage = UIImage()
    }
}
