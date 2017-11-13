//
//  ViewController.swift
//  Drop
//
//  Created by Camille Zhang on 10/18/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class LoginViewController: UIViewController {
    
    @IBOutlet weak var passwordInput: UITextField?
    @IBOutlet weak var usernameInput: UITextField?
    @IBOutlet weak var loginButton: UIButton?
    
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.passwordInput?.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.usernameInput?.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        if (self.usernameInput?.text == nil || self.passwordInput?.text == nil) {
            return
        }
        
        let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.usernameInput!.text!, password: self.passwordInput!.text! )
        self.passwordAuthenticationCompletion?.set(result: authDetails)
    }
    
    @objc func inputDidChange(_ sender:AnyObject) {
        if (self.usernameInput?.text != nil && self.passwordInput?.text != nil) {
            self.loginButton?.isEnabled = true
        } else {
            self.loginButton?.isEnabled = false
        }
    }
    
}

extension LoginViewController: AWSCognitoIdentityPasswordAuthentication {
    
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        DispatchQueue.main.async {
            if (self.usernameInput?.text == nil) {
                self.usernameInput?.text = authenticationInput.lastKnownUsername
            }
        }
    }
    
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

