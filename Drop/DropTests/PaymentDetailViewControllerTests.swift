//
//  PaymentDetailViewControllerTests.swift
//  DropTests
//
//  Created by Minghong Zhou on 12/14/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import XCTest
import Firebase
@testable import Drop

class PaymentDetailViewControllerTests: XCTestCase {
    var paymentDetailViewController: PaymentDetailViewController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "PaymentDetailViewController")
        paymentDetailViewController = vc as! PaymentDetailViewController
        paymentDetailViewController.person = "MINGHONG ZHOU"
        paymentDetailViewController.appDelegate.transactionDictionary = ["MINGHONG ZHOU" : [], "XINGYUAN DING": []]
        paymentDetailViewController.appDelegate.myOwnName = "SHIRLEY HE"
        let transaction1 = Transaction(transactionName: "transaction1", amount: 5.00, borrower: "MINGHONG ZHOU", lender: "SHIRLEY HE", timestamp: 1513301429, status: "incomplete", itemName: "tea")
        let transaction2 = Transaction(transactionName: "transaction2", amount: 2.00, borrower: "SHIRLEY HE", lender: "MINGHONG ZHOU", timestamp: 1513301428, status: "incomplete", itemName: "tea")
        let transaction3 = Transaction(transactionName: "transaction3", amount: 5.00, borrower: "XINGYUAN DING", lender: "SHIRLEY HE", timestamp: 1513301427, status: "incomplete", itemName: "tea")
        paymentDetailViewController.appDelegate.transactionDictionary["MINGHONG ZHOU"]!.append(transaction1)
        paymentDetailViewController.appDelegate.transactionDictionary["MINGHONG ZHOU"]!.append(transaction2)
        paymentDetailViewController.appDelegate.transactionDictionary["XINGYUAN DING"]!.append(transaction3)
        _ = paymentDetailViewController.view
   
        paymentDetailViewController.PaymentDetail.reloadData()
    }
    
    override func tearDown() {
        super.tearDown()
        paymentDetailViewController = nil
    }
    
    func testNumberOfTableSections() {
        XCTAssertTrue(paymentDetailViewController.PaymentDetail.numberOfSections == 1)
    }
    
    func testCellName() {
        let cell = paymentDetailViewController.PaymentDetail.cellForRow(at: IndexPath(row: 0, section: 0))
        XCTAssertTrue(cell?.textLabel?.text! == "tea")
    }
    
    func testCellSum() {
        let cell = paymentDetailViewController.PaymentDetail.cellForRow(at: IndexPath(row: 0, section: 0))
        XCTAssertTrue(cell?.detailTextLabel?.text! == "+ $5.0")
    }
    
    
    func testCellColor() {
        XCTAssertTrue(paymentDetailViewController.PaymentDetail.cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.textColor! == UIColor.init(red: 0.056, green: 0.8, blue: 0.056, alpha: 1))
    }
}
