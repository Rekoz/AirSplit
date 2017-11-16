//
//  EventViewControllerTests.swift
//  DropTests
//
//  Created by dingxingyuan on 11/15/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import XCTest
@testable import Drop

class EventViewControllerTests: XCTestCase {
    
    var eventViewController: EventViewController!
    var multipeer: MultipeerManager!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        eventViewController = storyboard.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        _ = eventViewController.view
        multipeer = MultipeerManager()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        eventViewController = nil
        multipeer = nil
    }
    
    func testCancelButton() {
        eventViewController.people.append("minghong")
        eventViewController.cancelButtonTapped({})
        XCTAssertTrue(eventViewController.people.count == 0)
    }
    
    func testDeviceDetection() {
        eventViewController.deviceDetection(manager: multipeer, detectedDevice:"minghong")
        XCTAssertTrue(eventViewController.people.count == 1)
    }
    
    func testlLoseDevice() {
        eventViewController.loseDevice(manager: multipeer, removedDevice: "minghong")
        XCTAssertTrue(eventViewController.people.count == 0)
    }
}
