//
//  AppDelegate.swift
//  Drop
//
//  Created by Camille Zhang on 10/18/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let multipeer = MultipeerManager()
    var people = [String]()
    var items = [[String]]()
    var myOwnName = ""
    
    var window: UIWindow?
    
    var storyboard: UIStoryboard? {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    var loginViewController: LoginViewController?
    var tabBarController: UITabBarController?
    var ref: DatabaseReference!
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("home clicked")
        self.people.removeAll()
        multipeer.delegate?.loseDevice(manager: multipeer, removedDevice: "anything")
    }
    
    /**
     Initializes app and set up AWS logger and AWS Cognito. Tells the delegate that the launch process is almost done and the app is almost ready to run.
     
     - Parameter application: A singleton app object.
     - Parameter launchOptions: A dictionary indicating the reason the app was launched.
     
     - Returns: false if the app cannot handle the URL resource or continue a user activity, otherwise return true. The return value is ignored if the app is launched as a result of a remote notification.
    */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(_ application: UIApplication, open url: URL,
                     sourceApplication: String?, annotation: Any) -> Bool {
        return true
    }
}
