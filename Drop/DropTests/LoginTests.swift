//
//  LoginTests.swift
//  DropTests
//
//  Created by Shirley He on 11/16/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import XCTest
@testable import Drop

/**
    Testings for login process.
 */
class LoginTests: XCTestCase {
    
    var vcLogin: LoginViewController!
    
    let email = "1234@gmail.com"
    let password = "123456"
    
    /**
     Initialize storyboard and login view controller.
    */
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        vcLogin = vc as! LoginViewController
        _ = vcLogin.view
    }
    
    /**
     Clean up login view controller.
    */
    override func tearDown() {
        vcLogin = nil
        super.tearDown()
    }
    
    /**
     If both username and password are non-empty, login button is enabled.
    */
    func testSubmitButtonEnabledWithCorrectInfo() {
        vcLogin.usernameInput?.text = self.email
        vcLogin.passwordInput?.text = self.password
        XCTAssertTrue((vcLogin.loginButton?.isEnabled)!)
    }
    
    func testSignUpButtonEnabledWithCorrectInfo() {
        vcLogin.signUpDidTouch("" as AnyObject)
        XCTAssertTrue((vcLogin.signUpButton?.isEnabled)!)
    }
}

