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
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        self.appDelegate = nil
    }
    
    func testGetAccountIconFromName() {
        let testImage = appDelegate.getAccountIconFromName(name: "Minghong Zhou")
        XCTAssertTrue(testImage.size.width > 0)
    }
}
