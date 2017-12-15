//
//  DropTests.swift
//  DropTests
//
//  Created by dingxingyuan on 11/13/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import XCTest
@testable import Drop

class MultipeerTests: XCTestCase {
    
    var multipeer: MultipeerManager!;
    
    override func setUp() {
        super.setUp()
        multipeer = MultipeerManager();
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        multipeer = nil;
        super.tearDown()
    }
    
    func testPeerDisplayName() {
        multipeer.setPeerDisplayName(name: "Minghong")
        XCTAssertTrue(multipeer.getPeerDisplayName() == "Minghong")
    }
    
    func testStartAdvertising() {
        multipeer.startAdvertising()
    }
    
    func testStartBrowsing() {
        multipeer.startBrowsing()
    }
}
