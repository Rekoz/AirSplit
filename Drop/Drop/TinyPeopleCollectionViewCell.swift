//
//  TinyPeopleCollectionViewCell.swift
//  Drop
//
//  Created by Shirley He on 12/4/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit

///Cell for display the detected device with its user's image and full name
class TinyPeopleCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var accountImageView: UIImageView!
    
    var accountName = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

