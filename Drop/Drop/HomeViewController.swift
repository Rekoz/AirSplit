//
//  HomeViewController.swift
//  Drop
//
//  Created by Camille Zhang on 10/22/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit
import Firebase

/**
    View controller that displays recent user activities.
 */

//extension String {
//    func capitalizingFirstLetter() -> String {
//        let first = String(characters.prefix(1)).capitalized
//        let other = String(characters.dropFirst())
//        return first + other
//    }
//
//    mutating func capitalizeFirstLetter() {
//        self = self.capitalizingFirstLetter()
//    }
//}
class HomeViewController: UIViewController {

    private var appDelegate : AppDelegate
    private var multipeer : MultipeerManager
    
    private var transactions = [Transaction]()
    @IBOutlet weak var NewsFeedTable: UITableView!
    
    var ref: DatabaseReference!
    
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
        ref = Database.database().reference()
        let email = Auth.auth().currentUser?.email
        findMyAccountName(email: email!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        transactions = [Transaction]()
        ref = Database.database().reference()
        self.findAllRelatedTransactions()
    }
    
    func findMyAccountName(email: String) {
        let query = ref.child("users").queryOrdered(byChild: "email").queryEqual(toValue: email)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            for case let childSnapshot as DataSnapshot in snapshot.children {
                if let data = childSnapshot.value as? [String: Any] {
                    print("got account name " + "\(data["accountName"]!)")
                    self.appDelegate.myOwnName = "\(data["accountName"]!)";
                    if (self.appDelegate.myOwnName != "") {
                        print("display name: " + self.appDelegate.myOwnName)
                        self.appDelegate.multipeer.setPeerDisplayName(name: self.appDelegate.myOwnName)
                        self.appDelegate.multipeer.startAdvertising()
                        self.findAllRelatedTransactions()
                    }
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func findAllRelatedTransactions() {
        transactions = [Transaction]()
        let myName = self.appDelegate.myOwnName
        print("my peer name: \(myName)")
        
        let queryByBorrower = ref.child("transactions").queryOrdered(byChild: "borrower").queryEqual(toValue: myName)
        
        let queryByLender = ref.child("transactions").queryOrdered(byChild: "lender").queryEqual(toValue: myName)
        
        queryByBorrower.observeSingleEvent(of: .value, with: { (snapshot) in
            for case let childSnapshot as DataSnapshot in snapshot.children {
                print("snapshot name: " + childSnapshot.key)
                if let data = childSnapshot.value as? [String: Any] {
                    if (data["status"] as! String == "complete" || data["status"] as! String == "declined" ) {
                        let peerIcon = self.getAccountIconFromName(name: data["lender"] as! String)
                        let transaction = Transaction(transactionName: childSnapshot.key, amount: data["amount"]! as! Double, borrower: "You", lender: "\(data["lender"]!)", timestamp: data["timestamp"]! as! Int, status: "complete", itemName: data["itemName"] as! String, icon: peerIcon)
                        print(transaction)
                        print("transactionName = " + childSnapshot.key)
                        print("amount = \(transaction.amount)")
                        print("borrower = \(transaction.borrower)")
                        print("lender = \(transaction.lender)")
                        print("timestamp = \(transaction.timestamp)")
                        print("itemName = " + transaction.itemName)
                        self.transactions.append(transaction)
                        print(self.transactions.count)
                    }
                    DispatchQueue.main.async {
                        self.transactions.sort(by: { $0.timestamp >= $1.timestamp })
                        self.NewsFeedTable.reloadData()
                    }
                }
            }
        })
        
        queryByLender.observeSingleEvent(of: .value, with: { (snapshot) in
            for case let childSnapshot as DataSnapshot in snapshot.children {
                if let data = childSnapshot.value as? [String: Any] {
                    if (data["status"] as! String == "complete" || data["status"] as! String == "declined" ) {
                        let peerIcon = self.getAccountIconFromName(name: data["borrower"] as! String)
                        let transaction = Transaction(transactionName: childSnapshot.key, amount: data["amount"]! as! Double, borrower: "\(data["borrower"]!)", lender: "you", timestamp: data["timestamp"]! as! Int, status: data["status"] as! String, itemName: data["itemName"] as! String, icon: peerIcon)
                        print(transaction)
                        print("transactionName = " + childSnapshot.key)
                        print("amount = \(transaction.amount)")
                        print("borrower = \(transaction.borrower)")
                        print("lender = \(transaction.lender)")
                        print("timestamp = \(transaction.timestamp)")
                        print("itemName = " + transaction.itemName)
                        self.transactions.append(transaction)
                        print(self.transactions.count)
                    }
                    DispatchQueue.main.async {
                        self.transactions.sort(by: { $0.timestamp >= $1.timestamp })
                        self.NewsFeedTable.reloadData()
                    }
                }
            }
        })
    }
    /**
     Logs out user when logout button is pressed.
     
     - Parameter sender: Client's action to press logout button.
    */
    @IBAction func logout(_ sender:AnyObject) {
        try! Auth.auth().signOut()
        dismiss(animated: true, completion: nil)
    }
    
    func getAccountIconFromName(name: String) -> UIImage {
        let lblNameInitialize = UILabel()
        lblNameInitialize.frame.size = CGSize(width: 30.0, height: 30.0)
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
}

//======================
//related to table view
//======================
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsFeedCell", for: indexPath) as! NewsFeedCell
        let transaction = self.transactions[indexPath.row]
        var payer = transaction.borrower
        payer = payer.capitalizeSentence(clause: payer)
        var payee = transaction.lender
        payee = payee.capitalizeSentence(clause: payee)
        let epochSec = transaction.timestamp
        let time = convertToDateTime(epochSec: epochSec)
        let amount = transaction.amount
        let icon = transaction.peer_icon
        print("payer: \(payer) payee: \(payee) time: \(time) amount:\(amount)")
        cell.Participants.text = "\(payer) paid \(payee)"
        cell.Amount.text = "$\(amount)"
        cell.Time.text = "\(time)"
        cell.Icon.image = icon
        return cell
    }
    
    func convertToDateTime(epochSec: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(epochSec))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: date)
    }
}
