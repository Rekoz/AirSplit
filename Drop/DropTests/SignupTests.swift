//
//  SignupTests.swift
//  DropTests
//
//  Created by Shirley He on 11/15/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import XCTest
@testable import Drop

/**
    Testings for registering new users.
 */
class SignupTests: XCTestCase {
    
    var vcSignup: SignupViewController!
    
    let firstname = "FIRST_NAME"
    let lastname = "LAST_NAME"
    let email = "1234@gmail.com"
    let password = "123456"
    let unmatched_password = "123"
    
    /**
     Initialize storyboard and signup view controller.
    */
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "SignupViewController")
        vcSignup = vc as! SignupViewController
        _ = vcSignup.view
    }
    
    /**
     Clean up signup view controller.
    */
    override func tearDown() {
        super.tearDown()
        vcSignup = nil
    }
    
    /**
     If any of the required registration info fields is empty, submit button is disabled.
    */
    func testSubmitButtonDisabledWithEmptyRegistrationInfo () {
        vcSignup.email.text = ""
        vcSignup.firstName.text = self.firstname
        vcSignup.lastName.text = self.lastname
        vcSignup.password.text = self.password
        vcSignup.confirmPassword.text = self.password
        vcSignup.inputDidChange("" as AnyObject)
        XCTAssertFalse(vcSignup.submitButton.isEnabled)
    }
    
    /**
     If password is not confirmed, submit button is disabled.
    */
    func testSubmitButtonDisabledWithUnmatchedConfirmPassword() {
        vcSignup.email.text = self.email
        vcSignup.firstName.text = self.firstname
        vcSignup.lastName.text = self.lastname
        vcSignup.password.text = self.password
        vcSignup.confirmPassword.text = self.unmatched_password
        vcSignup.inputDidChange("" as AnyObject)
        XCTAssertFalse(vcSignup.submitButton.isEnabled)
    }
    
    /**
     If all registration info are inputted correctly, submit button is enabled.
    */
    func testSubmitButtonEnabledWithCorrectInfo() {
        vcSignup.email.text = self.email
        vcSignup.firstName.text = self.firstname
        vcSignup.lastName.text = self.lastname
        vcSignup.password.text = self.password
        vcSignup.confirmPassword.text = self.password
        vcSignup.inputDidChange("" as AnyObject)
        XCTAssertTrue(vcSignup.submitButton.isEnabled)
    }
}
