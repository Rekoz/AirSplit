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
class HomeViewController: UIViewController {

    private var appDelegate : AppDelegate
    private var multipeer : MultipeerManager
    
    private var transactions = [Transaction]()
    @IBOutlet weak var NewsFeedTable: UITableView!
    
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
        self.multipeer.setPeerDisplayName(name: "Shirley He")
        self.multipeer.startAdvertising()
        self.transactions.append(Transaction.init())    // REMOVE--DEBUG
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Logs out user when logout button is pressed.
     
     - Parameter sender: Client's action to press logout button.
    */
    @IBAction func logout(_ sender:AnyObject) {
        try! Auth.auth().signOut()
        dismiss(animated: true, completion: nil)
    }
}

//======================
//related to table view
//======================
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactions.count
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsFeedCell", for: indexPath) as! NewsFeedCell
        cell.Participants.text = "You paid Camille"
        cell.Price.text = "$10.00"
        cell.Icon.image = #imageLiteral(resourceName: "icons8-User Male-48")
        return cell
    }
}
