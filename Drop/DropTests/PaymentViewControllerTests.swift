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
        paymentViewController.people = ["Minghong Zhou", "Xingyuan Ding"]
        paymentViewController.transactionDictionary = ["Minghong Zhou" : [], "Xingyuan Ding": []]
        let transaction1 = Transaction(transactionName: "transaction1", amount: 5.00, borrower: "Minghong Zhou", lender: "Shirley He", timestamp: 1513301429, status: "incomplete", itemName: "tea")
        let transaction2 = Transaction(transactionName: "transaction2", amount: 2.00, borrower: "Shirley He", lender: "Minghong Zhou", timestamp: 1513301428, status: "incomplete", itemName: "tea")
        let transaction3 = Transaction(transactionName: "transaction3", amount: 5.00, borrower: "Xingyuan Ding", lender: "Shirley He", timestamp: 1513301427, status: "incomplete", itemName: "tea")
        paymentViewController.transactionDictionary["Minghong Zhou"].append(transaction1)
        paymentViewController.transactionDictionary["Minghong Zhou"].append(transaction2)
        paymentViewController.transactionDictionary["Xingyuan Ding"].append(transaction3)
    }
    
    func testNumberOfTableEntries() {
        XCTAssertTrue(paymentViewController.PaymentCenterTableView.numberOfSections == 2)
    }
    
    func testCellSum() {
        XCTAssertTrue(paymentViewController.PaymentCenterTableView.cellForRow(at: IndexPath(row: 0, section: 0))?.textLabel?.text! == "+ $3.00")
    }
    
    func testCellColor() {
        XCTAssertTrue(paymentViewController.PaymentCenterTableView.cellForRow(at: IndexPath(row: 0, section: 0))?.textLabel?.textColor == UIColor.init(red: 0.056, green: 0.8, blue: 0.056, alpha: 1))
    }
}
