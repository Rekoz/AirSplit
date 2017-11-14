//
//  DropTests.swift
//  DropTests
//
//  Created by dingxingyuan on 11/13/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import XCTest

class DropTests: XCTestCase {
    
    var multipeer: MultipeerManager!;
    
    override func setUp() {
        super.setUp()
        multipeer = MultipeerManager();
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        multipeer = nil;
    }
    
    func testSetPeerDisplayName() {
        multipeer.setPeerDisplayName(name: "Zeyu")
    }
    
}
