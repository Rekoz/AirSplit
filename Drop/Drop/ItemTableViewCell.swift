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
    @IBOutlet weak var SplitButton: UIButton!
    @IBOutlet weak var AssigneeCollection: UICollectionView!
    
    weak var delegate: ItemTableViewCellDelegate?
    
    public var assignees = [PeopleCollectionViewCell]()
    
    @IBAction func add_item(_ sender: Any) {
        delegate?.cell_did_add_item(self)
    }

    @IBAction func add_people(_ sender: Any) {
        delegate?.cell_did_add_people(self)
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
    
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {
        
        AssigneeCollection.delegate = dataSourceDelegate
        AssigneeCollection.dataSource = dataSourceDelegate
        AssigneeCollection.tag = row
        AssigneeCollection.reloadData()
    }
}

extension ItemTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    /// Asks your data source object for the number of items in the specified section.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - section: An index number identifying a section in collectionView. This index value is 0-based.
    /// - Returns: number of detected devices in the people array if collectionView == PeopleCollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assignees.count
    }
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - indexPath: The index path that specifies the location of the item.
    /// - Returns: a peopleCollectionViewCell if collectionView == PeopleCollectionView
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssigneeCell", for: indexPath) as! TinyPeopleCollectionViewCell
        if indexPath.row < self.assignees.count {
            cell.accountImageView.image = self.assignees[indexPath.row].accountImageView.image
            cell.accountName = self.assignees[indexPath.row].accountName.text!
        }
        return cell
    }
}
