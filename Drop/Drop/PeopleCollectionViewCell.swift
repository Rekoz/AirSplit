//
//  PeopleCollectionViewCell.swift
//  Drop
//
//  Created by dingxingyuan on 11/5/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit

///Cell for display the detected device with its user's image and full name
class PeopleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var accountImageView: UIImageView!
    @IBOutlet weak var accountName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
