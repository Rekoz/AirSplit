//
//  User.swift
//  Drop
//
//  Created by Minghong Zhou on 12/3/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit

class User: NSObject {
    var userId: String
    var accountName: String
    var firstName: String
    var friends: [String]
    var lastName: String
    var profilePhoto: String
    
    init(userId: String, accountName: String, firstName: String, friends: [String],
         lastName: String, profilePhoto: String) {
        self.userId = userId
        self.accountName = accountName
        self.firstName = firstName
        self.friends = friends
        self.lastName = lastName
        self.profilePhoto = profilePhoto
    }
    
    convenience override init() {
        self.init(userId:  "", accountName: "", firstName: "", friends: [],
                  lastName: "", profilePhoto: "")
        
    }
}
