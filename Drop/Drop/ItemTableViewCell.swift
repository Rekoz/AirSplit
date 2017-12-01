//
//  ItemTableViewCell.swift
//  Drop
//
//  Created by Camille Zhang on 12/1/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    @IBOutlet weak var ItemName: UITextField!
    @IBOutlet weak var ItemPrice: UITextField!
    @IBOutlet weak var AddButton: UIButton!
    @IBAction func add_item(_ sender: Any) {
        self.AddButton.isHidden = true
        self.ItemName.placeholder = "Item Name"
        self.ItemPrice.placeholder = "Price"
    }
    @IBAction func add_people(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
