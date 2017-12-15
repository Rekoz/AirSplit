//
//  AppDelegateTest.swift
//  DropTests
//
//  Created by dingxingyuan on 12/14/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import XCTest
@testable import Drop

class AppDelegateTest: XCTestCase {
    
    var appDelegate: AppDelegate!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.appDelegate = nil
        super.tearDown()
    }
    
    func testGetAccountIconFromName() {
        let testImage = appDelegate.getAccountIconFromName(name: "Minghong Zhou")
        XCTAssertTrue(testImage.size.width > 0)
    }
}
