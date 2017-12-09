//
//  PaymentViewController.swift
//  Drop
//
//  Created by Camille Zhang on 10/27/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit
/**
    View controller that handles payment processing.
 */
class PaymentViewController: UIViewController {
    
    let paymentCellIdentifier = "PaymentCell"
    
    let data:[String] = ["Item 1", "Item 2", "Item 3"]
    
    /**
        Called after the controller's view is loaded into memory.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
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
        return data.count
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
        cell.textLabel?.text = data[indexPath.row]
        cell.detailTextLabel?.text = "price"
        //cell.detailTextLabel?.textColor = UIColor.init(red: 0.1924, green: 0.8, blue: 0.056, alpha: 1)
        cell.detailTextLabel?.textColor = UIColor.init(red: 0.8, green: 0.056, blue: 0.056, alpha: 1)
        return cell
    }
    
    /**
     Asks the data source to return the number of sections in the table view.
     
     - Parameter tableView: An object representing the table view requesting this information.
     
     - Returns: The number of sections in tableView. The default value is 1.
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

