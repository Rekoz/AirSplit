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
    
    // Define Firebase database reference
    var ref: DatabaseReference!
    
    private var appDelegate : AppDelegate
    
    /**
     Initialize LoginViewController.
    */
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        super.init(coder: aDecoder)
    }
    
    /**
     Authenticates user when login button is pressed.
     
     - Parameter sender: Client's action to press login button.
     
     - Returns: Returns immediately if either username or password is empty.
    */
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
    
    @IBAction func signUpDidTouch(_ sender: AnyObject) {
        let alert = UIAlertController(title: "",
                                      message: "Please enter your information",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Sign Up", style: .default)
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
                        self.ref.child("users").child(firstNameField.text! + "_" + lastNameField.text!).setValue(["accountName": firstNameField.text!.uppercased() + " " + lastNameField.text!.uppercased(), "firstName": firstNameField.text!, "lastName": lastNameField.text!, "email": emailField.text!])
                        
                    }
                    Auth.auth().signIn(withEmail: self.usernameInput.text!,
                                       password: self.passwordInput.text!)
                    print("Create User Successful")
                } else {
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

