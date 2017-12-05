//
//  Transaction.swift
//  Drop
//
//  Created by Minghong Zhou on 12/3/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit

class Transaction: NSObject {
    var transactionId: String
    var borrower: String
    var lender: String
    var transactionDate: String
    
    init(transactionId: String, borrower: String, lender: String, transactionDate: String) {
        self.transactionId = transactionId
        self.borrower = borrower
        self.lender = lender
        self.transactionDate = transactionDate
    }
    
    convenience override init() {
        self.init(transactionId: "", borrower: "", lender: "", transactionDate: "")
    }
}


