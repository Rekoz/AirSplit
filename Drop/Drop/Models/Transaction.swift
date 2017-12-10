//
//  Transaction.swift
//  Drop
//
//  Created by Minghong Zhou on 12/3/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit

class Transaction: NSObject {
    var amount: Double
    var borrower: String
    var lender: String
    var timestamp: Int
    
    init(amount: Double, borrower: String, lender: String, timestamp: Int) {
        self.amount = amount
        self.borrower = borrower
        self.lender = lender
        self.timestamp = timestamp
    }
    
    convenience override init() {
        self.init(amount: 0.00, borrower: "", lender: "", timestamp: 0)
    }
}


