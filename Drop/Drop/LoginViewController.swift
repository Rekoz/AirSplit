//
//  LoginViewController.swift
//  AirSplit
//
//  Created by Camille Zhang on 10/18/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit
import Firebase

/// View controller for user login.
class LoginViewController: UIViewController {
    
    let loginToHomeView = "LoginToHomeView"
    
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var loginButton: UIButton?
    @IBOutlet weak var signUpButton: UIButton!
    
    // Define Firebase database reference
    var ref: DatabaseReference!
    
    private var appDelegate : AppDelegate!
    
    /// Initialize LoginViewController.
    ///
    /// - Parameters:
    ///   - nibNameOrNil: The name of the nib file to associate with the view controller. The nib file name should not contain any leading path information. If you specify nil, the nibName property is set to nil.
    ///   - nibBundleOrNil: The bundle in which to search for the nib file. This method looks for the nib file in the bundle's language-specific project directories first, followed by the Resources directory. If this parameter is nil, the method uses the heuristics described below to locate the nib file.
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        super.init(coder: aDecoder)
    }
    
    /// Authenticates user when login button is pressed.
    ///
    /// - Parameter sender: Client's action to press login button.
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        Auth.auth().signIn(withEmail: usernameInput.text!,
                           password: passwordInput.text!)
        { user, error in
            if error == nil {
                print("Welcome \(user!.email!)")
                self.clearTextField()
            } else {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    var errorMessage = String()
                    switch errCode {
                    case .userNotFound:
                        errorMessage = "Email address not found"
                    case .invalidEmail:
                        errorMessage = "Invalid email address"
                    case .wrongPassword:
                        errorMessage = "Invalid password"
                    default:
                        errorMessage = "\(error)"
                    }
                    DispatchQueue.main.async {
                        let errorAlertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                        let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                        errorAlertController.addAction(retryAction)
                        self.present(errorAlertController, animated: true, completion: nil)
                    }
                    print("Sign In Error: \(error)")
                }
            }
        }
    }
    
    /// Register & authenticate user when user click "Don't have an account?"
    ///
    /// - Parameter sender: Signup button
    @IBAction func signUpDidTouch(_ sender: AnyObject) {
        
        // Generate a signup view
        let alert = UIAlertController(title: "",
                                      message: "Please enter your information",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Sign Up", style: .default)
        { action in
            
            // 1. Add user registration required information fields
            let firstNameField = alert.textFields![0]
            let lastNameField = alert.textFields![1]
            let emailField = alert.textFields![2]
            let passwordField = alert.textFields![3]
            
            // 2. Create user when all required info are filled in
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!)
            { user, error in
                if error == nil {
                    // 3. Authenticate user when registration is successful
                    if let user = user {
                        self.clearTextField()
                        print("We have new user! \(user.email!)")
                        self.ref.child("users").child(firstNameField.text! + "_" + lastNameField.text!).setValue(["accountName": firstNameField.text!.uppercased() + " " + lastNameField.text!.uppercased(), "firstName": firstNameField.text!, "lastName": lastNameField.text!, "email": emailField.text!])
                        
                    }
                    Auth.auth().signIn(withEmail: self.usernameInput.text!,
                                       password: self.passwordInput.text!)
                    print("Create User Successful")
                } else {
                    // 4. Alert user when registration is not successful
                    if let errCode = AuthErrorCode(rawValue: error!._code) {
                        var errorMessage = String()
                        switch errCode {
                        case .invalidEmail:
                            errorMessage = "Invalid email"
                        case .emailAlreadyInUse:
                            errorMessage = "Email alreay in use"
                        case .weakPassword:
                            errorMessage = "Password must have at least 6 characters"
                        default:
                            errorMessage = "\(error)"
                            print("Create User Error: \(error!)")
                        }
                        
                        DispatchQueue.main.async {
                            let errorAlertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                            errorAlertController.addAction(retryAction)
                            self.present(errorAlertController, animated: true, completion: nil)
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
            textPassword.placeholder = "Password (>= 6 characters)"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    /// Asks the delegate if the text field should process the pressing of the return button.
    ///
    /// - Parameter textField: The text field whose return button was pressed.
    /// - Returns: true if the text field should implement its default behavior for the return button; otherwise, false.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameInput {
            passwordInput.becomeFirstResponder()
        }
        if textField == passwordInput {
            textField.resignFirstResponder()
        }
        return true
    }
    
    /// Clear all inputs.
    func clearTextField() {
        self.usernameInput.text = ""
        self.passwordInput.text = ""
    }
}

extension LoginViewController {
    /// Hide keyboard on tap.
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
        Auth.auth().addStateDidChangeListener() { auth, user in
            // Segue to Home View when user is authenticated
            if user != nil {
                self.performSegue(withIdentifier: self.loginToHomeView, sender: nil)
            }
        }
        self.addHideKeyboardOnTap()
    }
}

