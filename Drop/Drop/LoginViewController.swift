//
//  LoginViewController.swift
//  AirSplit
//
//  Created by Camille Zhang on 10/18/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit
import Firebase

/**
    View controller for user login.
 */
class LoginViewController: UIViewController {
    
    let loginToSongView = "LoginToHomeView"
    
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var loginButton: UIButton?
    
    // [START define_database_reference]
    var ref: DatabaseReference!
    // [END define_database_reference]

    /**
     Authenticates user when login button is pressed.
     
     - Parameter sender: Client's action to press login button.
     
     - Returns: Returns immediately if either username or password is empty.
    */
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        Auth.auth().signIn(withEmail: usernameInput.text!,
                           password: passwordInput.text!) { user, error in
                            if error == nil {
                                print("Welcome \(user!.email!)")
                                self.clearTextField()
                            } else {
                                if let errCode = AuthErrorCode(rawValue: error!._code) {
                                    print("Sign In Error: \(errCode)")
                                }
                            }
                            
        }
    }
    
    @IBAction func signUpDidTouch(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default)
        { action in
            
            // 1
            let firstNameField = alert.textFields![0]
            let lastNameField = alert.textFields![1]
            let emailField = alert.textFields![2]
            let passwordField = alert.textFields![3]
            
            // 2
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!)
            { user, error in
                if error == nil {
                    // 3
                    if let user = user {
                        self.clearTextField()
                        print("We have new user! \(user.email!)")
                        self.ref.child("users").child(firstNameField.text! + "_" + lastNameField.text!).setValue(["accountName": firstNameField.text!.uppercased() + " " + lastNameField.text!.uppercased(), "firstName":firstNameField.text!, "lastName": lastNameField.text!])
                    }
                    Auth.auth().signIn(withEmail: self.usernameInput.text!,
                                       password: self.passwordInput.text!)
                    print("Create User Successful")
                } else {
                    if let errCode = AuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                        case .invalidEmail:
                            print("invalid email")
                        case .emailAlreadyInUse:
                            print("in use")
                        default:
                            print("Create User Error: \(error!)")
                        }
                    }
                }
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { textFirstName in
            textFirstName.placeholder = "First name"
        }
        
        alert.addTextField { textLastName in
            textLastName.placeholder = "Last name"
        }
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameInput {
            passwordInput.becomeFirstResponder()
        }
        if textField == passwordInput {
            textField.resignFirstResponder()
        }
        return true
    }
    func clearTextField() {
        self.usernameInput.text = ""
        self.passwordInput.text = ""
    }
}

extension LoginViewController {
    func addHideKeyboardOnTap()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(LoginViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

extension LoginViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        // 1
        Auth.auth().addStateDidChangeListener() { auth, user in
            // 2
            if user != nil {
                // 3
                self.performSegue(withIdentifier: self.loginToSongView, sender: nil)
            }
        }
        self.addHideKeyboardOnTap()
    }
}

