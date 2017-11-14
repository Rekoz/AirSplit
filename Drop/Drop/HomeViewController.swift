//
//  HomeViewController.swift
//  Drop
//
//  Created by Camille Zhang on 10/22/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class HomeViewController: UIViewController {

    private var appDelegate : AppDelegate
    private var multipeer : MultipeerManager
    
    var user:AWSCognitoIdentityUser?
    var userAttributes:[AWSCognitoIdentityProviderAttributeType]?
    
    /**
     Returns a newly initialized view controller with the nib file in the specified bundle.
     
     - Parameters:
        - nibNameOrNil: The name of the nib file to associate with the view controller. The nib file name should not contain any leading path information. If you specify nil, the nibName property is set to nil.
        - nibBundleOrNil: The bundle in which to search for the nib file. This method looks for the nib file in the bundle's language-specific project directories first, followed by the Resources directory. If this parameter is nil, the method uses the heuristics described below to locate the nib file.
     
     - Returns: A newly initialized UIViewController object.
    */
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.multipeer = appDelegate.multipeer
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.multipeer = appDelegate.multipeer
        super.init(coder: aDecoder)
    }
    
    /**
     Called after the controller's view is loaded into memory.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.multipeer.setPeerDisplayName(name: "123")
        self.multipeer.startAdvertising()
        self.fetchUserAttributes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Fetches user info when user is logged in.
     
     - Returns: nil when user info is retrieved succesfully.
    */
    func fetchUserAttributes() {
        user = AppDelegate.defaultUserPool().currentUser()
        user?.getDetails().continueOnSuccessWith(block: { (task) -> Any? in
            guard task.result != nil else {
                return nil
            }
            self.userAttributes = task.result?.userAttributes
            self.userAttributes?.forEach({ (attribute) in
                print("Name: " + attribute.name!)
            })
            return nil
        })
    }
    
    /**
     Retrieves attribute value based on provided attribute key.
     
     - Parameter name: attribute key.
     
     - Returns: attribute value.
    */
    func valueForAttribute(name:String) -> String? {
        let values = self.userAttributes?.filter { $0.name == name }
        return values?.first?.value
    }
    
    /**
     Logs out user when logout button is pressed.
     
     - Parameter sender: Client's action to press logout button.
    */
    @IBAction func logout(_ sender:AnyObject) {
        user?.signOut()
        self.fetchUserAttributes()
    }
}
