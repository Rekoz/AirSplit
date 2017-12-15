//
//  SearchTableViewCell.swift
//  Drop
//
//  Created by Minghong Zhou on 12/4/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit

//use Protocol
protocol SearchTableCellDelegate: class {
    func cell_clicked(_ sender: SearchTableCell)
}

class SearchTableCell: UITableViewCell {

    @IBOutlet weak var SearchImage: UIImageView!
    @IBOutlet weak var SearchName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
