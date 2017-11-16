//
//  AppDelegate.swift
//  Drop
//
//  Created by Camille Zhang on 10/18/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

let userPoolID = "SampleUserPool"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let multipeer = MultipeerManager()
    
    var window: UIWindow?
    
    var storyboard: UIStoryboard? {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    var rememberDeviceCompletionSource: AWSTaskCompletionSource<NSNumber>?
    var loginViewController: LoginViewController?
    var tabBarController: UITabBarController?
    var cognitoConfig: CognitoConfig?
    class func defaultUserPool() -> AWSCognitoIdentityUserPool {
        return AWSCognitoIdentityUserPool(forKey: userPoolID)
    }
    
    /**
     Initializes app and set up AWS logger and AWS Cognito. Tells the delegate that the launch process is almost done and the app is almost ready to run.
     
     - Parameter application: A singleton app object.
     - Parameter launchOptions: A dictionary indicating the reason the app was launched.
     
     - Returns: false if the app cannot handle the URL resource or continue a user activity, otherwise return true. The return value is ignored if the app is launched as a result of a remote notification.
    */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // setup logging
        AWSDDLog.sharedInstance.logLevel = .verbose
        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
        
        // setup cognito config
        self.cognitoConfig = CognitoConfig()
        
        // setup cognito
        setupCognitoUserPool()
        
        // Override point for customization after application launch.
        return true
    }

    /**
     Set up AWS Cognito User Pool based on the configurations specified in CognitoConfig.plist.
    */
    func setupCognitoUserPool() {
        let clientId:String = self.cognitoConfig!.getClientId()
        let poolId:String = self.cognitoConfig!.getPoolId()
        let clientSecret:String = self.cognitoConfig!.getClientSecret()
        let region:AWSRegionType = self.cognitoConfig!.getRegion()
        
        let serviceConfiguration:AWSServiceConfiguration = AWSServiceConfiguration(region: region, credentialsProvider: nil)
        let cognitoConfiguration:AWSCognitoIdentityUserPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: clientId, clientSecret: clientSecret, poolId: poolId)
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: cognitoConfiguration, forKey: userPoolID)
        let pool:AWSCognitoIdentityUserPool = AppDelegate.defaultUserPool()
        pool.delegate = self
    }
    
}

extension AppDelegate: AWSCognitoIdentityInteractiveAuthenticationDelegate {
    
    /**
     Initialize ui to prompt end user for username and password.
     
     - Returns: LoginViewController.
    */
    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        
        if(self.tabBarController == nil) {
            self.tabBarController = self.window?.rootViewController as? UITabBarController
        }

        if(self.loginViewController == nil) {
            self.loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        }
        
        DispatchQueue.main.async {
            if(self.loginViewController!.isViewLoaded || self.loginViewController!.view.window == nil) {
                self.tabBarController?.present(self.loginViewController!, animated: true, completion: nil)
            }
        }
        
        return self.loginViewController!
    }

}
