//
//  Transaction.swift
//  Drop
//
//  Created by Minghong Zhou on 12/3/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit

class Transaction: NSObject {
    var transactionName: String
    var amount: Double
    var borrower: String
    var lender: String
    var timestamp: Int
    var peer_icon: UIImage
    var status: String
    var itemName: String
    
    init(transactionName: String, amount: Double, borrower: String, lender: String, timestamp: Int, status: String, itemName: String, icon: UIImage) {
        self.transactionName = transactionName
        self.amount = amount
        self.borrower = borrower
        self.lender = lender
        self.timestamp = timestamp
        self.status = status
        self.itemName = itemName
        self.peer_icon = icon
    }
    
    init(transactionName: String, amount: Double, borrower: String, lender: String, timestamp: Int, status: String, itemName: String) {
        self.transactionName = transactionName
        self.amount = amount
        self.borrower = borrower
        self.lender = lender
        self.timestamp = timestamp
        self.status = status
        self.itemName = itemName
        self.peer_icon = #imageLiteral(resourceName: "icons8-User Male-48")
    }
    
    convenience override init() {
        self.init(transactionName: "", amount: 0.00, borrower: "", lender: "", timestamp: 0, status: "incomplete", itemName: "", icon: #imageLiteral(resourceName: "icons8-User Male-48"))
    }
}


