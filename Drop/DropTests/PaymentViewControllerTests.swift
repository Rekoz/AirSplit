//
//  PaymentViewControllerTests.swift
//  DropTests
//
//  Created by Minghong Zhou on 12/14/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import XCTest
import Firebase
@testable import Drop

class PaymentViewControllerTests: XCTestCase {
    var paymentViewController: PaymentViewController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "PaymentViewController")
        paymentViewController = vc as! PaymentViewController
        _ = paymentViewController.view
        paymentViewController.people = ["MINGHONG ZHOU", "XINGYUAN DING"]
        paymentViewController.appDelegate.transactionDictionary = ["MINGHONG ZHOU" : [], "XINGYUAN DING": []]
        paymentViewController.appDelegate.myOwnName = "SHIRLEY HE"
        let transaction1 = Transaction(transactionName: "transaction1", amount: 5.00, borrower: "MINGHONG ZHOU", lender: "SHIRLEY HE", timestamp: 1513301429, status: "incomplete", itemName: "tea")
        let transaction2 = Transaction(transactionName: "transaction2", amount: 2.00, borrower: "SHIRLEY HE", lender: "MINGHONG ZHOU", timestamp: 1513301428, status: "incomplete", itemName: "tea")
        let transaction3 = Transaction(transactionName: "transaction3", amount: 5.00, borrower: "XINGYUAN DING", lender: "SHIRLEY HE", timestamp: 1513301427, status: "incomplete", itemName: "tea")
        paymentViewController.appDelegate.transactionDictionary["MINGHONG ZHOU"]!.append(transaction1)
        paymentViewController.appDelegate.transactionDictionary["MINGHONG ZHOU"]!.append(transaction2)
        paymentViewController.appDelegate.transactionDictionary["XINGYUAN DING"]!.append(transaction3)
        paymentViewController.PaymentCenterTableView.reloadData()
    }
    
    override func tearDown() {
        paymentViewController = nil
        super.tearDown()
    }
    
    func testNumberOfTableSections() {
        print("number of cells" + String(paymentViewController.PaymentCenterTableView.numberOfSections))
        XCTAssertTrue(paymentViewController.PaymentCenterTableView.numberOfSections == 1)
    }
    
    func testCellName() {
        let cell = paymentViewController.PaymentCenterTableView.cellForRow(at: IndexPath(row: 0, section: 0))
        print("sum test: " + (cell?.textLabel?.text)!)
        XCTAssertTrue(cell?.textLabel?.text! == "Minghong Zhou")
    }
    
    func testCellSum() {
        let cell = paymentViewController.PaymentCenterTableView.cellForRow(at: IndexPath(row: 0, section: 0)) 
        print("sum test: " + (cell?.detailTextLabel?.text)!)
        XCTAssertTrue(cell?.detailTextLabel?.text! == "+ $3.0")
    }
    
    
    func testCellColor() {
        XCTAssertTrue(paymentViewController.PaymentCenterTableView.cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.textColor! == UIColor.init(red: 0.056, green: 0.8, blue: 0.056, alpha: 1))
    }
}
