//
//  HomeViewControllerTests.swift
//  DropTests
//
//  Created by dingxingyuan on 12/14/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import XCTest
@testable import Drop

class HomeViewControllerTests: XCTestCase {
    
    var homeViewController: HomeViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        homeViewController = vc as! HomeViewController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        homeViewController = nil
        super.tearDown()
    }
    
    func testConvertToDateTime() {
        let data = homeViewController.convertToDateTime(epochSec: 1513302878)
        XCTAssertTrue(data == "2017-12-14 17:54")
    }
    
}
