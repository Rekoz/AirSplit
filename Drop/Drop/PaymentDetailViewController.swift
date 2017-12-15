//
//  PaymentDetailViewController.swift
//  Drop
//
//  Created by Yunong Jiang on 12/9/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit
import Firebase

/// Controller for displaying detailed payments between a peer.
class PaymentDetailViewController: UIViewController {

    var person = ""
    var transactions:[Transaction] = []
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
    
    @IBOutlet weak var PaymentDetail: UITableView!
    
    /// This function takes care of toggling Cancel/Select function
    ///
    /// - Parameters:
    ///   - editing: A table-view object requesting the cell.
    ///   - animated: An index path locating a row in tableView.
    override func setEditing(_ editing: Bool, animated: Bool) {
        PaymentDetail.setEditing(editing,animated:animated)
        if (editing) {
            self.navigationItem.rightBarButtonItem!.title = "Cancel"
        } else {
            self.navigationItem.rightBarButtonItem!.title = "Select"
        }
    }
    
    /// Callback for when the "Select" or "Cancel" button is clicked. When it is
    /// clicked as "Select", it puts the table view into edit mode, enables the
    /// "Confirm" button and changes its text label to "Cancel". When it is clicked
    /// as "Cancel", it exits the table view from edit mode, disables the "Confirm"
    /// button and changes its text label to "Select".
    ///
    /// - Parameter sender: The UIBarButtonItem that triggers the function
    @IBAction func CheckItems(_ sender: UIBarButtonItem) {
        if (sender.title! == "Select") {
            self.setEditing(true, animated: true)
            self.navigationItem.rightBarButtonItems![1].isEnabled = true
        } else {
            self.setEditing(false, animated: true)
            self.navigationItem.rightBarButtonItems![1].isEnabled = false
        }
    }

    /// This function find out which transactions to delete and update the payment detail
    /// table view with the updated transactions
    ///
    /// - Parameter sender: A UIBarButtonItem that triggers the function
    @IBAction func SubmitItems(_ sender: UIBarButtonItem) {
        var items : [String] = []
        var itemsToDelete: [String] = []
        let selectedIndexPaths = PaymentDetail.indexPathsForSelectedRows
        if selectedIndexPaths != nil {
            for indexPath in selectedIndexPaths! {
                let cell = PaymentDetail.cellForRow(at: indexPath)
                items.append((cell?.textLabel?.text)!)
                let transactionToBeDeleted = self.transactions[indexPath.row]
                itemsToDelete.append(transactionToBeDeleted.transactionName)
                print("delete: " + transactionToBeDeleted.transactionName)
                self.deleteTransaction(transactionToBeDeleted: transactionToBeDeleted.transactionName, transaction: transactionToBeDeleted)
            }
        }
        self.transactions = self.transactions.filter{ !itemsToDelete.contains($0.transactionName)}
        self.setEditing(false, animated: true)
        self.navigationItem.rightBarButtonItems![1].isEnabled = false
        self.PaymentDetail.reloadData()
    }
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        var name = person
        name = name.capitalizeSentence(clause: name)
        self.title = name
        ref = Database.database().reference()

        // Do any additional setup after loading the view.
        self.PaymentDetail.delegate = self
        self.PaymentDetail.dataSource = self
        
        print(person)
        print(self.appDelegate.transactionDictionary)
        for transaction in self.appDelegate.transactionDictionary[person]! {
            self.transactions.append(transaction)
        }
    }

    /// The number of rows in section.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// This function takes in the original transaction and update the database with new
    /// transaction by changing the status of the original transaction to either declined or
    /// complete depending on whether the user is the lender or the borrower
    ///
    /// - Parameters:
    ///   - transactionToBeDeleted: the transactionName of the transaction to be updated to complete/ decline
    ///   - transaction: original transaction
    func deleteTransaction(transactionToBeDeleted: String, transaction: Transaction) {
        var status: String = "complete"
        if transaction.lender == self.appDelegate.myOwnName {
            status = "declined"
        }
        let transaction = ["amount": transaction.amount, "borrower": transaction.borrower, "lender": transaction.lender, "timestamp": transaction.timestamp, "status": status, "itemName": transaction.itemName] as [String : Any]
        
        let childUpdate = ["/transactions/" + transactionToBeDeleted: transaction]
        ref.updateChildValues(childUpdate)
        self.appDelegate.findAllRelatedTransactions()
    }
}

extension PaymentDetailViewController: UITableViewDataSource, UITableViewDelegate {
    /// Tells the data source to return the number of rows in a given section of a table view.
    ///
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section in tableView.
    /// - Returns: The number of rows in section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    ///
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. An assertion is raised if you return nil.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        cell.textLabel?.text = self.transactions[indexPath.row].itemName
        
    
        if self.transactions[indexPath.row].lender == person{
            cell.detailTextLabel?.textColor = UIColor.init(red: 0.8, green: 0.056, blue: 0.056, alpha: 1)
            cell.detailTextLabel?.text = "- $" + String(self.transactions[indexPath.row].amount)
        } else {
            cell.detailTextLabel?.textColor = UIColor.init(red: 0.056, green: 0.8, blue: 0.056, alpha: 1)
            cell.detailTextLabel?.text = "+ $" + String(self.transactions[indexPath.row].amount)
        }
        return cell
    }
}
