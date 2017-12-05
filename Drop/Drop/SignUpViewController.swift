//
//  SignUpViewController.swift
//  AirSplit
//
//  Created by Shirley He on 11/7/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import Firebase

/**
    View controller for registering new users.
 */
class SignupViewController : UIViewController {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    // [START define_database_reference]
    var ref: DatabaseReference!
    // [END define_database_reference]
    
    var user: AWSCognitoIdentityUser?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // [START create_database_reference]
        ref = Database.database().reference()
        // [END create_database_reference]
    }
    
    /**
     Notifies the view controller that its view is about to be added to a view hierarchy.
     
     - Parameter animated: If true, the view is being added to the window using an animation.
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.submitButton.isEnabled = false
        self.firstName.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.lastName.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.email.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.password.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.confirmPassword.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
    }
    
    /**
     Enables register button if none of the required user information is empty or if confirmed password does not match with password, disables otherwise.
     
     - Parameter sender: Client's action to enter/clear registration information.
     
     - Returns: Returns immediately if any of the required fields is empty.
     */
    @objc func inputDidChange(_ sender:AnyObject) {
        if(firstName.text == "" || lastName.text == "") {
            self.submitButton.isEnabled = false
            return
        }
        if(email.text == "") {
            self.submitButton.isEnabled = false
            return
        }
        if(password.text == "" || confirmPassword.text == "") {
            self.submitButton.isEnabled = false
            return
        }
        self.submitButton.isEnabled = (password.text == confirmPassword.text)
    }
    
    /**
     Registers user when register button is pressed. If registration is successful, this function dismisses signup view. Otherwise, it displays an error.
     
     - Parameter sender: Client's action to press register button.
     
     - Returns: nil.
     */
    @IBAction func signupPressed(_ sender: AnyObject) {
        let userPool = AppDelegate.defaultUserPool()
        let emailAttribute = AWSCognitoIdentityUserAttributeType(name: "email", value: email.text!)
        let firstNameAttribute = AWSCognitoIdentityUserAttributeType(name: "given_name", value: firstName.text!)
        let lastNameAttribute = AWSCognitoIdentityUserAttributeType(name: "family_name", value: lastName.text!)
        let attributes:[AWSCognitoIdentityUserAttributeType] = [emailAttribute, firstNameAttribute, lastNameAttribute];
        userPool.signUp(email.text!, password: password.text!, userAttributes: attributes, validationData: nil)
            .continueWith { (response) -> Any? in

                DispatchQueue.main.async {
                    if response.error != nil {
                        let alert = UIAlertController(title: "Error", message: (response.error! as NSError).userInfo["message"] as? String, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.user = response.result!.user
                        self.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                }
                return nil
        }
        self.ref.child("users").child(firstName.text! + "_" + lastName.text!).setValue(["accountName": firstName.text!.uppercased() + " " + lastName.text!.uppercased(), "firstName":firstName.text!, "lastName": lastName.text!])
    }
    
    @IBAction func backPressed(_ sender: AnyObject) {
        DispatchQueue.main.async {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
