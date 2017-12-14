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
    var peer_icon: UIImage
    
    init(amount: Double, borrower: String, lender: String, timestamp: Int, icon: UIImage) {
        self.amount = amount
        self.borrower = borrower
        self.lender = lender
        self.timestamp = timestamp
        self.peer_icon = icon
    }
    
    convenience override init() {
        self.init(amount: 0.00, borrower: "", lender: "", timestamp: 0, icon: #imageLiteral(resourceName: "icons8-User Male-48"))
    }
}


