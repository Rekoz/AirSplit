//
//  ItemTableViewCell.swift
//  Drop
//
//  Created by Camille Zhang on 12/1/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit

//use Protocol
protocol ItemTableViewCellDelegate: class {
    func cell_did_add_item(_ sender: ItemTableViewCell)
    func cell_did_add_people(_ sender: ItemTableViewCell)
}
class ItemTableViewCell: UITableViewCell {
    @IBOutlet weak var ItemName: UITextField!
    @IBOutlet weak var ItemPrice: UITextField!
    @IBOutlet weak var AddButton: UIButton!
    
    weak var delegate: ItemTableViewCellDelegate?
    
    @IBAction func add_item(_ sender: Any) {
        delegate?.cell_did_add_item(self)
    }

    @IBAction func add_people(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
