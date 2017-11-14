//
//  LoginViewController.swift
//  AirSplit
//
//  Created by Camille Zhang on 10/18/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

/**
    View controller for user login.
 */
class LoginViewController: UIViewController {
    
    @IBOutlet weak var passwordInput: UITextField?
    @IBOutlet weak var usernameInput: UITextField?
    @IBOutlet weak var loginButton: UIButton?
    
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    
    /**
     Notifies the view controller that its view is about to be added to a view hierarchy.
     
     - Parameter animated: If true, the view is being added to the window using an animation.
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.passwordInput?.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.usernameInput?.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
    }
    
    /**
     Authenticates user when login button is pressed.
     
     - Parameter sender: Client's action to press login button.
     
     - Returns: Returns immediately if either username or password is empty.
    */
    @IBAction func loginPressed(_ sender: AnyObject) {
        if (self.usernameInput?.text == nil || self.passwordInput?.text == nil) {
            return
        }
        
        let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.usernameInput!.text!, password: self.passwordInput!.text! )
        self.passwordAuthenticationCompletion?.set(result: authDetails)
    }
    
    /**
     Enables login button if neither username nor password is empty, disables otherwise.
     
     - Parameter sender: Client's action to enter/clear username or password.
    */
    @objc func inputDidChange(_ sender:AnyObject) {
        if (self.usernameInput?.text != nil && self.passwordInput?.text != nil) {
            self.loginButton?.isEnabled = true
        } else {
            self.loginButton?.isEnabled = false
        }
    }
    
}

extension LoginViewController: AWSCognitoIdentityPasswordAuthentication {
    
    /**
     Obtains username and password from end user.
     
     - Parameters:
        - authenticationInput: input details including last known username.
        - passwordAuthenticationCompletionSource: set passwordAuthenticationCompletionSource.result with the username and password received from the end user.
    */
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        DispatchQueue.main.async {
            if (self.usernameInput?.text == nil) {
                self.usernameInput?.text = authenticationInput.lastKnownUsername
            }
        }
    }
    
    /**
     Logs in user when login button is pressed. If login is successful, this function dismisses login view and proceed to home view. Otherwise, it displays an error.
     
     - Parameter error: the error if any that occured.
    */
    public func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if error != nil {
                let alertController = UIAlertController(title: "Cannot Login",
                                                        message: (error! as NSError).userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                self.present(alertController, animated: true, completion:  nil)
            } else {
                self.dismiss(animated: true, completion: {
                    self.usernameInput?.text = nil
                    self.passwordInput?.text = nil
                })
            }
        }
    }
    
}

