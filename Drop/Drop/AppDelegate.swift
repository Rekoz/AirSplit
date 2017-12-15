//
//  AppDelegate.swift
//  Drop
//
//  Created by Camille Zhang on 10/18/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let multipeer = MultipeerManager()
    var people = [String]()
    var items = [[String]]()
    var myOwnName = ""
    var transactionDictionary = [String: [Transaction]]()
    
    var window: UIWindow?
    
    /// Retrieve main storyboard
    var storyboard: UIStoryboard? {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    var loginViewController: LoginViewController?
    var tabBarController: UITabBarController?
    var ref: DatabaseReference!
    
    /// Tells the delegate that the app is about to become inactive. Clear multipeer array.
    ///
    /// - Parameter application: Your singleton app object.
    func applicationWillResignActive(_ application: UIApplication) {
        print("home clicked")
        self.people.removeAll()
        multipeer.delegate?.loseDevice(manager: multipeer, removedDevice: "anything")
        self.people.append(myOwnName)
    }
    
    /// Initializes app and set up AWS logger and AWS Cognito. Tells the delegate that the launch process is almost done and the app is almost ready to run.
    ///
    /// - Parameters:
    ///   - application: A singleton app object.
    ///   - launchOptions: A dictionary indicating the reason the app was launched.
    /// - Returns: false if the app cannot handle the URL resource or continue a user activity, otherwise return true. The return value is ignored if the app is launched as a result of a remote notification.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        ref = Database.database().reference()
        findAllRelatedTransactions()
        return true
    }
    
    func application(_ application: UIApplication, open url: URL,
                     sourceApplication: String?, annotation: Any) -> Bool {
        return true
    }

    /// Generate an account icon based on user's initials.
    ///
    /// - Parameter name: user's account name
    /// - Returns: an image with user's initials.
    func getAccountIconFromName(name: String) -> UIImage {
        let lblNameInitialize = UILabel()
        lblNameInitialize.frame.size = CGSize(width: 45.0, height: 45.0)
        lblNameInitialize.textColor = UIColor.white
        var nameStringArr = name.components(separatedBy: " ")
        let firstName: String = nameStringArr[0].uppercased()
        let firstLetter: Character = firstName[0]
        let lastName: String = nameStringArr[1].uppercased()
        let secondLetter: Character = lastName[0]
        lblNameInitialize.text = String(firstLetter) + String(secondLetter)
        lblNameInitialize.textAlignment = NSTextAlignment.center
        lblNameInitialize.layer.cornerRadius = lblNameInitialize.frame.size.width/2
        lblNameInitialize.layer.backgroundColor = UIColor.black.cgColor
        
        UIGraphicsBeginImageContext(lblNameInitialize.frame.size)
        lblNameInitialize.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    /// Retrieve user's recently activities from Firebase. Append query results to Transaction dictionary.
    func findAllRelatedTransactions() {
        transactionDictionary = [String: [Transaction]]()
        
        // transactions paid by user
        let queryByBorrower = ref.child("transactions").queryOrdered(byChild: "borrower").queryEqual(toValue: myOwnName)
        
        // transactions paid by peers
        let queryByLender = ref.child("transactions").queryOrdered(byChild: "lender").queryEqual(toValue: myOwnName)
        
        // append query results to transaction dictionary
        queryByBorrower.observeSingleEvent(of: .value, with: { (snapshot) in
            for case let childSnapshot as DataSnapshot in snapshot.children {
                print("snapshot name: " + childSnapshot.key)
                if let data = childSnapshot.value as? [String: Any] {
                    if (data["status"] as! String == "incomplete") {
                        let transaction = Transaction(transactionName: childSnapshot.key, amount: data["amount"]! as! Double, borrower: "\(data["borrower"]!)", lender: "\(data["lender"]!)", timestamp: data["timestamp"]! as! Int, status: "incomplete", itemName: data["itemName"] as! String)
                        print(transaction)
                        print("transactionName = " + childSnapshot.key)
                        print("amount = \(transaction.amount)")
                        print("borrower = \(transaction.borrower)")
                        print("lender = \(transaction.lender)")
                        print("timestamp = \(transaction.timestamp)")
                        print("itemName = " + transaction.itemName)
                        if (!self.people.contains(transaction.lender)) {
                            self.people.append(transaction.lender)
                            self.transactionDictionary[transaction.lender] = [Transaction]()
                            self.transactionDictionary[transaction.lender]?.append(transaction)
                            print(self.transactionDictionary[transaction.lender]!)
                            print(self.people)
                        } else {
                            self.transactionDictionary[transaction.lender]?.append(transaction)
                        }
                        DispatchQueue.main.async {
                            self.people.sort(by: {$0 < $1})
                        }
                    }
                }
            }
        })
        
        // append query results to transaction dictionary
        queryByLender.observeSingleEvent(of: .value, with: { (snapshot) in
            for case let childSnapshot as DataSnapshot in snapshot.children {
                if let data = childSnapshot.value as? [String: Any] {
                    if (data["status"] as! String == "incomplete") {
                        let transaction = Transaction(transactionName: childSnapshot.key, amount: data["amount"]! as! Double, borrower: "\(data["borrower"]!)", lender: "\(data["lender"]!)", timestamp: data["timestamp"]! as! Int, status: "incomplete", itemName: data["itemName"] as! String)
                        print(transaction)
                        print("transactionName = " + childSnapshot.key)
                        print("amount = \(transaction.amount)")
                        print("borrower = \(transaction.borrower)")
                        print("lender = \(transaction.lender)")
                        print("timestamp = \(transaction.timestamp)")
                        print("itemName = " + transaction.itemName)
                        if (!self.people.contains(transaction.borrower)) {
                            self.people.append(transaction.borrower)
                            self.transactionDictionary[transaction.borrower] = [Transaction]()
                            self.transactionDictionary[transaction.borrower]?.append(transaction)
                            print(self.transactionDictionary[transaction.borrower]!)
                            print(self.people)
                        } else {
                            self.transactionDictionary[transaction.borrower]?.append(transaction)
                        }
                        DispatchQueue.main.async {
                            self.people.sort(by: {$0 < $1})
                        }
                    }
                }
            }
        })
    }
}
