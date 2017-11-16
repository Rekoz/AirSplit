//
//  SignupTests.swift
//  DropTests
//
//  Created by Shirley He on 11/15/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import XCTest
@testable import Drop

class SignupTests: XCTestCase {
    
    var vcSignup: SignupViewController!
    
    let firstname = "FIRST_NAME"
    let lastname = "LAST_NAME"
    let email = "1234@gmail.com"
    let password = "123456"
    let unmatched_password = "123"
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "SignupViewController")
        vcSignup = vc as! SignupViewController
        _ = vcSignup.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        vcSignup = nil
    }
    
    func testSubmitButtonDisabledWithEmptyRegistrationInfo () {
        vcSignup.email.text = nil
        vcSignup.firstName.text = self.firstname
        vcSignup.lastName.text = self.lastname
        vcSignup.password.text = self.password
        vcSignup.confirmPassword.text = self.password
        vcSignup.inputDidChange("" as AnyObject)
        XCTAssertFalse(vcSignup.submitButton.isEnabled)
    }
    
    func testSubmitButtonDisabledWithUnmatchedConfirmPassword() {
        vcSignup.email.text = self.email
        vcSignup.firstName.text = self.firstname
        vcSignup.lastName.text = self.lastname
        vcSignup.password.text = self.password
        vcSignup.confirmPassword.text = self.unmatched_password
        vcSignup.inputDidChange("" as AnyObject)
        XCTAssertFalse(vcSignup.submitButton.isEnabled)
    }
    
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
