//
//  SignUpViewController.swift
//  Drop
//
//  Created by Shirley He on 11/7/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class SignupViewController : UIViewController {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    var user: AWSCognitoIdentityUser?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.submitButton.isEnabled = false
        self.firstName.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.lastName.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.email.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.password.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.confirmPassword.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
    }
    
    @objc func inputDidChange(_ sender:AnyObject) {
        if(firstName.text == nil || lastName.text == nil) {
            self.submitButton.isEnabled = false
            return
        }
        if(email.text == nil) {
            self.submitButton.isEnabled = false
            return
        }
        if(password.text == nil || confirmPassword.text == nil) {
            self.submitButton.isEnabled = false
            return
        }
        self.submitButton.isEnabled = (password.text == confirmPassword.text)
    }
    
    @IBAction func signupPressed(_ sender: AnyObject) {
        let userPool = AppDelegate.defaultUserPool()
        let emailAttribute = AWSCognitoIdentityUserAttributeType(name: "email", value: email.text!)
        let firstNameAttribute = AWSCognitoIdentityUserAttributeType(name: "given_name", value: firstName.text!)
        let lastNameAttribute = AWSCognitoIdentityUserAttributeType(name: "family_name", value: lastName.text!)
        let attributes:[AWSCognitoIdentityUserAttributeType] = [emailAttribute, firstNameAttribute, lastNameAttribute];
        userPool.signUp(email.text!, password: password.text!, userAttributes: attributes, validationData: nil)
            .continueWith { (response) -> Any? in
                if response.error != nil {
                    // Error in the Signup Process
                    let alert = UIAlertController(title: "Error", message: (response.error! as NSError).userInfo["message"] as? String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.user = response.result!.user
                    DispatchQueue.main.async {
                        self.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                }
                return nil
        }
    }
    
}
