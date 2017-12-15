//
//  HomeViewController.swift
//  Drop
//
//  Created by Camille Zhang on 10/22/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit
import Firebase

/// View controller that displays recent user activities.
class HomeViewController: UIViewController {

    var appDelegate : AppDelegate!
    private var multipeer : MultipeerManager
    
    private var transactions = [Transaction]()
    @IBOutlet weak var NewsFeedTable: UITableView!
    
    // Define Firebase reference
    var ref: DatabaseReference!
    
    /// Returns a newly initialized view controller with the nib file in the specified bundle.
    ///
    /// - Parameters:
    ///   - nibNameOrNil: The name of the nib file to associate with the view controller. The nib file name should not contain any leading path information. If you specify nil, the nibName property is set to nil.
    ///   - nibBundleOrNil: The bundle in which to search for the nib file. This method looks for the nib file in the bundle's language-specific project directories first, followed by the Resources directory. If this parameter is nil, the method uses the heuristics described below to locate the nib file.
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
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        let email = Auth.auth().currentUser?.email
        findMyAccountName(email: email!)
    }
    
    /// Reload recent transactions from Firebase every time Home view appears.
    ///
    /// - Parameter animated: whether view will appear
    override func viewWillAppear(_ animated: Bool) {
        transactions = [Transaction]()
        ref = Database.database().reference()
        self.findAllRelatedTransactions()
    }
    
    /// Retrieve user's account name for the use of recent transaction queries.
    ///
    /// - Parameter email: user's email address
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
    
    /// Retrieve user's recently completed/declined transactions from Firebase. Append query results to Transaction array.
    func findAllRelatedTransactions() {
        transactions = [Transaction]()
        let myName = self.appDelegate.myOwnName
        print("my peer name: \(myName)")
        
        // transactions paid by user
        let queryByBorrower = ref.child("transactions").queryOrdered(byChild: "borrower").queryEqual(toValue: myName)
        
        // transactions paid by peers
        let queryByLender = ref.child("transactions").queryOrdered(byChild: "lender").queryEqual(toValue: myName)
        
        // append chronologically sorted query results to transaction dictionary
        queryByBorrower.observeSingleEvent(of: .value, with: { (snapshot) in
            for case let childSnapshot as DataSnapshot in snapshot.children {
                print("snapshot name: " + childSnapshot.key)
                if let data = childSnapshot.value as? [String: Any] {
                    if (data["status"] as! String == "complete" || data["status"] as! String == "declined" ) {
                        let peerIcon = self.appDelegate.getAccountIconFromName(name: data["lender"] as! String)
                        let lender = data["lender"] as! String
                        let capitalizedLender = lender.capitalizeSentence(clause: lender)
                        let transaction = Transaction(transactionName: childSnapshot.key, amount: data["amount"]! as! Double, borrower: "You", lender: "\(capitalizedLender)", timestamp: data["timestamp"]! as! Int, status: data["status"] as! String, itemName: data["itemName"] as! String, icon: peerIcon)
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
        
        // append chronologically sorted query results to transaction dictionary
        queryByLender.observeSingleEvent(of: .value, with: { (snapshot) in
            for case let childSnapshot as DataSnapshot in snapshot.children {
                if let data = childSnapshot.value as? [String: Any] {
                    if (data["status"] as! String == "complete" || data["status"] as! String == "declined" ) {
                        let peerIcon = self.appDelegate.getAccountIconFromName(name: data["borrower"] as! String)
                        let borrower = data["borrower"] as! String
                        let capitalizedBorrower = borrower.capitalizeSentence(clause: borrower)
                        let transaction = Transaction(transactionName: childSnapshot.key, amount: data["amount"]! as! Double, borrower: "\(capitalizedBorrower)", lender: data["status"] as! String == "declined" ? "You" : "you", timestamp: data["timestamp"]! as! Int, status: data["status"] as! String, itemName: data["itemName"] as! String, icon: peerIcon)
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
     Logs out user when logout button is pressed. Return to Login View after completion.
     
     - Parameter sender: Client's action to press logout button.
    */
    @IBAction func logout(_ sender:AnyObject) {
        try! Auth.auth().signOut()
//        dismiss(animated: true, completion: nil)
        let vc : UIViewController = self.appDelegate.storyboard!.instantiateViewController(withIdentifier: "LoginViewController") as UIViewController
        self.present(vc, animated: false, completion: nil)
    }
}

//======================
//related to table view
//======================
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    /// Tells the data source to return the number of rows in a given section of a table view.
    ///
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section in tableView.
    /// - Returns: The number of rows in section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactions.count
    }
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    ///
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. An assertion is raised if you return nil.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsFeedCell", for: indexPath) as! NewsFeedCell
        let transaction = self.transactions[indexPath.row]
        let payer = transaction.borrower
        let payee = transaction.lender
        let epochSec = transaction.timestamp
        let time = convertToDateTime(epochSec: epochSec)
        let amount = transaction.amount
        let icon = transaction.peer_icon
        let status = transaction.status
        print("payer: \(payer) payee: \(payee) time: \(time) amount:\(amount)")
        if status == "declined" {
            if payer.lowercased() == "you" {
                cell.Participants.text = "\(payee) completed your transaction"
            } else {
                cell.Participants.text = "\(payee) completed \(payer)'s transaction"
            }
        } else {
            if payee.lowercased() == "you" {
                cell.Participants.text = "\(payer) completed your transaction"
            } else {
                cell.Participants.text = "\(payer) completed \(payee)'s transaction"
            }
        }
        cell.Amount.text = "$\(amount)"
        cell.Time.text = "\(time)"
        cell.Icon.image = icon
        return cell
    }
    
    /// Convert Epoch seconds to datetime.
    ///
    /// - Parameter epochSec: epoch seconds
    /// - Returns: a datetime string in format yyyy-MM-dd HH:mm
    func convertToDateTime(epochSec: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(epochSec))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: date)
    }
}
