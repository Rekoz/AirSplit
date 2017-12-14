//
//  PaymentViewController.swift
//  Drop
//
//  Created by Camille Zhang on 10/27/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit
import Firebase
/**
    View controller that handles payment processing.
 */
class PaymentViewController: UIViewController {
    
    @IBOutlet weak var PaymentCenterTableView: UITableView!
    let paymentCellIdentifier = "PaymentCell"
    
    var people:[String] = []
    
    var transactionDictionary = [String: [Transaction]]()
    
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
    /**
        Called after the controller's view is loaded into memory.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        // [START create_database_reference]
        ref = Database.database().reference()
        // [END create_database_reference]
        findAllRelatedTransactions()
        
        self.PaymentCenterTableView.delegate = self
        self.PaymentCenterTableView.dataSource = self
        
    }

    /**
        Sent to the view controller when the app receives a memory warning.
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//related to payment Tableview
extension PaymentViewController: UITableViewDataSource, UITableViewDelegate {
    
    /**
     Tells the data source to return the number of rows in a given section of a table view.
     
     - Parameters:
        tableView: The table-view object requesting this information.
        section: An index number identifying a section in tableView.
     
     - Returns: The number of rows in section.
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    /**
     Asks the data source for a cell to insert in a particular location of the table view.
     
     - Parameters:
        tableView: A table-view object requesting the cell.
        indexPath: An index path locating a row in tableView.
     
     - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. An assertion is raised if you return nil.
     
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: paymentCellIdentifier, for: indexPath)
        cell.textLabel?.text = people[indexPath.row]
        cell.detailTextLabel?.text = "price"
        //cell.detailTextLabel?.textColor = UIColor.init(red: 0.1924, green: 0.8, blue: 0.056, alpha: 1)
        cell.detailTextLabel?.textColor = UIColor.init(red: 0.8, green: 0.056, blue: 0.056, alpha: 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PaymentCenterToDetail", sender: people[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailView = segue.destination as! PaymentDetailViewController
        detailView.person = sender as! String
    }
    
    /**
     Asks the data source to return the number of sections in the table view.
     
     - Parameter tableView: An object representing the table view requesting this information.
     
     - Returns: The number of sections in tableView. The default value is 1.
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func findAllRelatedTransactions() {
        let myName = self.appDelegate.myOwnName
        print("my peer name: \(myName)")
        
        //        print("key: " + ref.child("transactions").childByAutoId().key)
        //        let transaction = ["amount": 66, "borrower": "CAMILLE ZHANG", "lender": "MINGHONG ZHOU", "timestamp": 1512871247, "status": "complete"] as [String : Any]
        //
        //        let childUpdate = ["/transactions/transaction1512871247": transaction]
        //
        //        ref.updateChildValues(childUpdate)
        
        let queryByBorrower = ref.child("transactions").queryOrdered(byChild: "borrower").queryEqual(toValue: myName)
        
        let queryByLender = ref.child("transactions").queryOrdered(byChild: "lender").queryEqual(toValue: myName)
        
        queryByBorrower.observeSingleEvent(of: .value, with: { (snapshot) in
            for case let childSnapshot as DataSnapshot in snapshot.children {
                print("snapshot name: " + childSnapshot.key)
                if let data = childSnapshot.value as? [String: Any] {
                    if (data["status"] as! String == "incomplete") {
                        let peerIcon = self.getAccountIconFromName(name: data["borrower"] as! String)
                        let transaction = Transaction(transactionName: childSnapshot.key, amount: data["amount"]! as! Double, borrower: "\(data["borrower"]!)", lender: "\(data["lender"]!)", timestamp: data["timestamp"]! as! Int, status: "incomplete", itemName: data["itemName"] as! String, icon: peerIcon)
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
                            self.PaymentCenterTableView.reloadData()
                        }
                    }
                }
            }
        })
        
        queryByLender.observeSingleEvent(of: .value, with: { (snapshot) in
            for case let childSnapshot as DataSnapshot in snapshot.children {
                if let data = childSnapshot.value as? [String: Any] {
                    if (true) {
                        let peerIcon = self.getAccountIconFromName(name: data["borrower"] as! String)
                        let transaction = Transaction(transactionName: childSnapshot.key, amount: data["amount"]! as! Double, borrower: "\(data["borrower"]!)", lender: "\(data["lender"]!)", timestamp: data["timestamp"]! as! Int, status: "incomplete", itemName: data["itemName"] as! String, icon: peerIcon)
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
                            self.PaymentCenterTableView.reloadData()
                            self.appDelegate.transactionDictionary = self.transactionDictionary
                        }
                    }
                }
            }
        })
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

