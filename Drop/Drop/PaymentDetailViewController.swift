//
//  PaymentDetailViewController.swift
//  Drop
//
//  Created by Yunong Jiang on 12/9/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit
import Firebase

class PaymentDetailViewController: UIViewController {

    var person = ""
    var transactions:[Transaction] = []
    var ref: DatabaseReference!
    
    private var appDelegate : AppDelegate
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var PaymentDetail: UITableView!
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        PaymentDetail.setEditing(editing,animated:animated)
        if (editing) {
            self.navigationItem.rightBarButtonItem!.title = "Cancel"
        } else {
            self.navigationItem.rightBarButtonItem!.title = "Select"
        }
    }
    
    @IBAction func CheckItems(_ sender: UIBarButtonItem) {
        if (sender.title! == "Select") {
            self.setEditing(true, animated: true)
            self.navigationItem.rightBarButtonItems![1].isEnabled = true
        } else {
            self.setEditing(false, animated: true)
            self.navigationItem.rightBarButtonItems![1].isEnabled = false
        }
    }
    
    @IBAction func SubmitItems(_ sender: UIBarButtonItem) {
        var items : [String] = []
        let selectedIndexPaths = PaymentDetail.indexPathsForSelectedRows
        if selectedIndexPaths != nil {
            for indexPath in selectedIndexPaths! {
                let cell = PaymentDetail.cellForRow(at: indexPath)
                items.append((cell?.textLabel?.text)!)
                var transactionToBeDeleted = self.transactions.filter{ $0.itemName == (cell?.textLabel?.text)! }[0]
                self.transactions = self.transactions.filter{ $0.itemName != (cell?.textLabel?.text)! }
                print("delete: " + transactionToBeDeleted.transactionName)
                self.deleteTransaction(transactionToBeDeleted: transactionToBeDeleted.transactionName, transaction: transactionToBeDeleted)
            }
        }
        print(items)
        print(transactions)
        self.PaymentDetail.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func deleteTransaction(transactionToBeDeleted: String, transaction: Transaction) {
        let transaction = ["amount": transaction.amount, "borrower": transaction.borrower, "lender": transaction.lender, "timestamp": transaction.timestamp, "status": "complete", "itemName": transaction.itemName] as [String : Any]
        
        let childUpdate = ["/transactions/" + transactionToBeDeleted: transaction]
        ref.updateChildValues(childUpdate)
        self.appDelegate.findAllRelatedTransactions()
    }
}

extension PaymentDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
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
