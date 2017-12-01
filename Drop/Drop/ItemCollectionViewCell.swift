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
    private var index : Int
    
    @IBAction func addButton(_ sender: Any) {
        if (add_button.title(for: .normal) == "Add") {
            itemName.placeholder = "Item Name"
            itemPrice.placeholder = "Price"
            add_button.setTitle("Delete", for: .normal)
            let next_index = self.index + 1
            print ("next index" + String(next_index))
            self.appDelegate.items.append(next_index)
            if let i = self.appDelegate.items.index(of: next_index) {
                self.appDelegate.multipeer.delegate?.addItems(index: i)
            }
        } else {
            if let i = self.appDelegate.items.index(of: self.index) {
                self.appDelegate.multipeer.delegate?.removeItems(index: i)
            }
        }
    }
    
    override init(frame: CGRect) {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.index = self.appDelegate.items[self.appDelegate.items.count - 1]
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.index = self.appDelegate.items[self.appDelegate.items.count - 1]
        print ("self index" + String(self.index))
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

