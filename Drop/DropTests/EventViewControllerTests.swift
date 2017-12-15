//
//  EventViewControllerTests.swift
//  DropTests
//
//  Created by dingxingyuan on 11/15/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import XCTest
import Firebase
@testable import Drop

class EventViewControllerTests: XCTestCase {
    
    var eventViewController: EventViewController!
    var multipeer: MultipeerManager!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        eventViewController = storyboard.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "EventViewController")
        eventViewController = vc as! EventViewController
        _ = eventViewController.view
        multipeer = MultipeerManager()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        eventViewController = nil
        multipeer = nil
        super.tearDown()
    }
    
    func testCancelButton() {
        eventViewController.getAppDelegate().people.append("minghong")
        eventViewController.cancelButtonTapped({})
        XCTAssertTrue(eventViewController.getAppDelegate().people.count == 0)
    }
    
    func testDeviceDetection() {
        eventViewController.deviceDetection(manager: multipeer, detectedDevice:"minghong")
        XCTAssertTrue(eventViewController.getAppDelegate().people.count == 1)
    }
    
    func testlLoseDevice() {
        eventViewController.loseDevice(manager: multipeer, removedDevice: "minghong")
        XCTAssertTrue(eventViewController.getAppDelegate().people.count == 0)
    }
    
    func testAddImage() {
        eventViewController.addImage({})
        // Check to see if the actionSheet items are correctly shown
        XCTAssertTrue(eventViewController.actionSheet.actions.count == 3)
        XCTAssertTrue(eventViewController.actionSheet.actions[0].title == "Camera")
        XCTAssertTrue(eventViewController.actionSheet.actions[1].title == "Photo Library")
        XCTAssertTrue(eventViewController.actionSheet.actions[2].title == "Cancel")
    }
    
    func testCreateBody() {
        let params = [
            "A": "A",
            "B": "B"
        ];
        let imageData = NSMutableData() as Data
        let convertedBody = eventViewController.createBody(parameters: params, boundary: "123", data: imageData, mimeType: "image/jpg", filename: "abc.jpg")
        
        // Check if the mimeType section has the correct content and format
        let targetMimeType = NSMutableData()
        targetMimeType.appendString("--123\r\nContent-Disposition: form-data; name=\"file\"; filename=\"abc.jpg\"\r\nContent-Type: image/jpg\r\n")
        XCTAssertNotNil(convertedBody.range(of: targetMimeType as Data))
        
        // Check if the parameter section has the correct content and format
        let targetParam = NSMutableData()
        targetParam.appendString("--123\r\nContent-Disposition: form-data; name=\"A\"\r\n\r\nA")
        XCTAssertNotNil(convertedBody.range(of: targetParam as Data))
    }
    
    func testStoreTransactions() {
        // Test the behavior after user has assigned items and submitted
        eventViewController.getAppDelegate().items = [
            ["Item1", "0"],
            ["Item2", "0"],
            ["Item3", "0"],
        ]
        
        // There is unassigned item(s)
        eventViewController.storeTransactions({})
        
        let appDelegate = eventViewController.getAppDelegate()
        eventViewController.assignees[0] = ["A"]
        eventViewController.assignees.append([String]())
        eventViewController.assignees.append([String]())
        
        XCTAssertTrue(appDelegate.items.count == 3)
        XCTAssertTrue(eventViewController.assignees.count == 3)
        
        eventViewController.assignees[1].append("B")
        eventViewController.assignees[2].append("C")

        // All items have been assigned. List should be submitted to server and cleared
        eventViewController.storeTransactions({})
        
        XCTAssertTrue(appDelegate.items.count == 1)
        XCTAssertTrue(eventViewController.assignees.count == 1)
    }
    
    func testConvertToDictionary() {
        let JSONObj = [
            "A": "1",
            "B": [ "C": "2"]
        ] as [String : Any]
        let dataToConvert = try! JSONSerialization.data(withJSONObject: JSONObj)
        let conversionResult = eventViewController.convertToDictionary(text: dataToConvert)
        XCTAssertEqual(JSONObj["A"] as! String, conversionResult["A"] as! String)
        XCTAssertNotNil(conversionResult["B"])
        XCTAssertEqual(JSONObj["B"] as! [String : String], conversionResult["B"] as! [String: String])
    }
    
    func testSearchBar() {
        // Test when search field is empty
        eventViewController.searchBar(UISearchBar.init(), textDidChange: "")
        let searchResults = eventViewController.getSearchResults()
        XCTAssertTrue(searchResults.count == 0)
        XCTAssertTrue(eventViewController.SearchTable.isHidden)
    }
}
