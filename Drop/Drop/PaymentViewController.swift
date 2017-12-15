//
//  PaymentViewController.swift
//  Drop
//
//  Created by Camille Zhang on 10/27/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit
import Firebase

/// View controller that handles payment processing with peers.
class PaymentViewController: UIViewController {
    
    @IBOutlet weak var PaymentCenterTableView: UITableView!
    let paymentCellIdentifier = "PaymentCell"
    
    var people:[String] = []
    
    var transactionDictionary = [String: [Transaction]]()
    
    var ref: DatabaseReference!
    
    var appDelegate : AppDelegate!
    
    /// Returns a newly initialized view controller with the nib file in the specified bundle.
    ///
    /// - Parameters:
    ///   - nibNameOrNil: The name of the nib file to associate with the view controller. The nib file name should not contain any leading path information. If you specify nil, the nibName property is set to nil.
    ///   - nibBundleOrNil: The bundle in which to search for the nib file. This method looks for the nib file in the bundle's language-specific project directories first, followed by the Resources directory. If this parameter is nil, the method uses the heuristics described below to locate the nib file.
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        super.init(coder: aDecoder)
    }

    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.PaymentCenterTableView.delegate = self
        self.PaymentCenterTableView.dataSource = self
        
    }
    
   override func viewWillAppear(_ animated: Bool) {
        ref = Database.database().reference()
        findAllRelatedTransactions()
        PaymentCenterTableView.reloadData()
    }
    
    /// Sent to the view controller when the app receives a memory warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//related to payment Tableview
extension PaymentViewController: UITableViewDataSource, UITableViewDelegate {
    
    /// Tells the data source to return the number of rows in a given section of a table view.
    ///
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section in tableView.
    /// - Returns: The number of rows in section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    ///
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. An assertion is raised if you return nil.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: paymentCellIdentifier, for: indexPath)
        var name = people[indexPath.row]
        name = name.capitalizeSentence(clause: name)
        cell.textLabel?.text = name
        var sum = 0.00
        for transation in self.appDelegate.transactionDictionary[people[indexPath.row]]! {
            if transation.lender == self.appDelegate.myOwnName {
               sum += transation.amount
            } else {
               sum -= transation.amount
            }
            
        }
        if sum >= 0.00 {
            cell.detailTextLabel?.text = "+ $" + String(sum)
            cell.detailTextLabel?.textColor = UIColor.init(red: 0.056, green: 0.8, blue: 0.056, alpha: 1)
        } else {
            cell.detailTextLabel?.text = "- $" + String(-sum)
            cell.detailTextLabel?.textColor = UIColor.init(red: 0.8, green: 0.056, blue: 0.056, alpha: 1)
        }
        
        return cell
    }
    
    /// Tells the delegate that the specified row is now selected.
    ///
    /// - Parameters:
    ///   - tableView: A table-view object informing the delegate about the new row selection.
    ///   - indexPath: An index path locating the new selected row in tableView.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PaymentCenterToDetail", sender: people[indexPath.row])
    }
    
    /// Notifies the view controller that a segue is about to be performed.
    ///
    /// - Parameters:
    ///   - segue: The segue object containing information about the view controllers involved in the segue.
    ///   - sender: The object that initiated the segue. You might use this parameter to perform different actions based on which control (or other object) initiated the segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailView = segue.destination as! PaymentDetailViewController
        detailView.person = sender as! String
    }
    
    /// Asks the data source to return the number of sections in the table view.
    ///
    /// - Parameter tableView: An object representing the table view requesting this information.
    /// - Returns: The number of sections in tableView. The default value is 1.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// Retrieve user's recently activities from Firebase.
    /// Append query results to Transaction dictionary.
    func findAllRelatedTransactions() {
        people = []
        transactionDictionary = [String: [Transaction]]()
        let myName = self.appDelegate.myOwnName
        print("my peer name: \(myName)")
        
        let queryByBorrower = ref.child("transactions").queryOrdered(byChild: "borrower").queryEqual(toValue: myName)
        
        let queryByLender = ref.child("transactions").queryOrdered(byChild: "lender").queryEqual(toValue: myName)
        
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
                            self.PaymentCenterTableView.reloadData()
                            self.appDelegate.transactionDictionary = self.transactionDictionary
                        }
                    }
                }
            }
        })
        
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
                            self.PaymentCenterTableView.reloadData()
                            self.appDelegate.transactionDictionary = self.transactionDictionary
                        }
                    }
                }
            }
        })
    }

}

