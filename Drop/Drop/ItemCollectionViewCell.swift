//
//  ItemCollectionViewCell.swift
//  Drop
//
//  Created by dingxingyuan on 11/30/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit


///Cell for display the detected device with its user's image and full name
class ItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var itemPrice: UITextField!
    @IBOutlet weak var add_button: UIButton!
    private var appDelegate : AppDelegate
    
    @IBAction func addButton(_ sender: Any) {
        self.itemName.placeholder = "Item Name"
        self.itemPrice.placeholder = "Price"
        self.add_button.isHidden = true
        self.appDelegate.items.append("item")
        let index = self.appDelegate.items.count - 1
        self.appDelegate.multipeer.delegate?.reloadItemView(index: index)
    }
    
    override init(frame: CGRect) {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

