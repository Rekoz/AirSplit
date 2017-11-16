//
//  EventViewControllerTests.swift
//  DropTests
//
//  Created by dingxingyuan on 11/15/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import XCTest

class EventViewControllerTests: XCTestCase {
    
    var eventViewController: EventViewController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        eventViewController = storyboard.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        _ = eventViewController.view
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        eventViewController = nil
    }
}
