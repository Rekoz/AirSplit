//
//  PaymentDetailViewController.swift
//  Drop
//
//  Created by Yunong Jiang on 12/9/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit

class PaymentDetailViewController: UIViewController {

    var person = ""
    var data:[String] = ["Item 1", "Item 2", "Item 3"]
    
    @IBOutlet weak var PaymentDetail: UITableView!
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        PaymentDetail.setEditing(editing,animated:animated)
        if (editing) {
            self.navigationItem.rightBarButtonItem!.title = "Done"
        } else {
            self.navigationItem.rightBarButtonItem!.title = "Edit"
        }
    }
    
    @IBAction func CheckItems(_ sender: UIBarButtonItem) {
        if (sender.title! == "Edit") {
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
        for indexPath in selectedIndexPaths! {
            let cell = PaymentDetail.cellForRow(at: indexPath)
            items.append((cell?.textLabel?.text)!)
        }
        print(items)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.PaymentDetail.delegate = self
        self.PaymentDetail.dataSource = self
        
        print(person)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PaymentDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.detailTextLabel?.text = "price"
        //cell.detailTextLabel?.textColor = UIColor.init(red: 0.1924, green: 0.8, blue: 0.056, alpha: 1)
        cell.detailTextLabel?.textColor = UIColor.init(red: 0.8, green: 0.056, blue: 0.056, alpha: 1)
        return cell
    }
}
