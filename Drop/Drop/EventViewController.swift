//
//  EventViewController.swift
//  Drop
//
//  Created by Camille Zhang on 10/22/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit
import Firebase

// MARK: - Customize capitalization for user account name.
extension String {
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[Range(start ..< end)])
    }
    
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    // Mutate string
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    // Split words then capitalize first letters.
    func capitalizeSentence(clause:String) -> String {
        var strArray = clause.components(separatedBy: " ")
        var result = ""
        for str in strArray {
            var newStr = str.lowercased()
            newStr.capitalizeFirstLetter()
            result += newStr
            result += " "
        }
        if result.count > 0 {
            return result.substring(to: result.index(before: result.endIndex))
        } else {
            return result
        }
    }
}

/// Controller that handles user's actions on event creating page.
class EventViewController: UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UISearchBarDelegate{
    
    let itemCellIdentifier = "ItemCell"
    let participantPopIdentifier = "ParticipantPopCell"
    var actionSheet: UIAlertController!
    var imagePickerController: UIImagePickerController!
    var deleteItemIndexPath : NSIndexPath? = nil
    
    @IBOutlet weak var ItemTableView: UITableView!
    @IBOutlet weak var PeopleCollectionView: UICollectionView!
    @IBOutlet weak var SearchButton: UISearchBar!
    @IBOutlet weak var SearchTable: UITableView!
    @IBOutlet weak var LoadingIndicator: UIActivityIndicatorView!
    
    // Define Firebase reference
    var ref: DatabaseReference!
    private var appDelegate : AppDelegate!
    private var multipeer : MultipeerManager
    
    private var splitable : Bool
    private var splitAtIndex: Int
    private var tempAssignees = [String]()
    private var searchResults = [String]()
    var assignees = [[String]]()
    private var taxAmount: Float
    private var taxPercentage: Float
    
    func getAppDelegate() -> AppDelegate {
        return appDelegate
    }
    
    func getSearchResults() -> [String] {
        return searchResults
    }
    
    /// Returns a newly initialized view controller with the nib file in the specified bundle.
    ///
    /// - Parameters:
    ///   - nibNameOrNil: The name of the nib file to associate with the view controller. The nib file name should not contain any leading path information. If you specify nil, the nibName property is set to nil.
    ///   - nibBundleOrNil: The bundle in which to search for the nib file. This method looks for the nib file in the bundle's language-specific project directories first, followed by the Resources directory. If this parameter is nil, the method uses the heuristics described below to locate the nib file.
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.multipeer = appDelegate.multipeer
        self.splitable = false
        self.splitAtIndex = -1
        self.taxAmount = 0
        self.taxPercentage = 0
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.multipeer = appDelegate.multipeer
        self.splitable = false
        self.splitAtIndex = -1
        self.taxAmount = 0
        self.taxPercentage = 0
        super.init(coder: aDecoder)
    }

    /// Prepare camera & database and clear cache when view did load.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SearchButton.delegate = self
        ref = Database.database().reference()
        
        actionSheet = UIAlertController(title: "Image Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        // Initialize image picker
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        // Prepare camera
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            } else {
                print("Camera not available")
            }
        }))
        
        // Prepare photo library
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction) in
        }))
        
        // related to item table view
        self.appDelegate.items.append(["item", "price"])
        self.assignees.append([String]())
        
        // Dismiss keyboard on tap
        //self.addHideKeyboardOnTap()
    }
    
    /// clear the detected devices array and start browsing when we get to the event creating page every time
    ///
    /// - Parameter animated: boolean
    override func viewWillAppear(_ animated: Bool) {
        self.appDelegate.people.removeAll()
        self.appDelegate.people.append(self.appDelegate.myOwnName)
        self.PeopleCollectionView.reloadData()
        self.ItemTableView.reloadData()
        self.multipeer.delegate = self
        self.multipeer.startBrowsing()
    }

    /// Sent to the view controller when the app receives a memory warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Handler for canceling a split event.
    ///
    /// - Parameter sender: cancel button
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.appDelegate.people.removeAll()
        self.appDelegate.items.removeAll()
        self.assignees.removeAll()
        let vc : UIViewController = self.appDelegate.storyboard!.instantiateViewController(withIdentifier: "home") as UIViewController
        self.present(vc, animated: false, completion: nil)
    }
    
    /// The callback function for when the Camera button is clicked.
    ///
    /// - Parameter sender: add-image button
    @IBAction func addImage(_ sender: Any) {
        self.present(actionSheet, animated: true, completion: nil)
    }

    /// The callback function for when the submit button is clicked
    ///
    /// - Parameter sender: submit button
    @IBAction func storeTransactions(_ sender: Any) {
//        print("current time is" + String(Int(NSDate().timeIntervalSince1970)))
        // Validate transaction inputs
        if (self.appDelegate.items.count == 1) {
            let errorMessage = "No Item Found"
            let errorAlertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            errorAlertController.addAction(retryAction)
            self.present(errorAlertController, animated: true, completion: nil)
            return
        }
        for i in 0..<self.appDelegate.items.count-1 {
            if (self.appDelegate.items[i][0] == "item" || self.appDelegate.items[i][0] == "") {
                let errorMessage = "Item Name Cannot Be Empty"
                let errorAlertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                errorAlertController.addAction(retryAction)
                self.present(errorAlertController, animated: true, completion: nil)
                return
            }
            if (self.appDelegate.items[i][1] == "price" || self.appDelegate.items[i][1] == "") {
                let errorMessage = "Item Price Cannot Be Empty"
                let errorAlertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                errorAlertController.addAction(retryAction)
                self.present(errorAlertController, animated: true, completion: nil)
                return
            }
            if (self.assignees[i].count == 0) {
                print("i "+String(i))
                let errorMessage = "You Have An Unsplitted Item"
                let errorAlertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                errorAlertController.addAction(retryAction)
                self.present(errorAlertController, animated: true, completion: nil)
                return
            }
        }
        // Divide amount & assign transactions
        for i in 0..<self.appDelegate.items.count-1 {
            let splitCount = self.assignees[i].count
            let item = self.appDelegate.items[i][0]
            let price = Double(self.appDelegate.items[i][1])
            let splitAmount = round(price! / Double(splitCount) * 100) / 100
            for j in 0..<self.assignees[i].count {
                if (self.assignees[i][j] != self.appDelegate.myOwnName) {
                    print ("save to db " + self.assignees[i][j] + " " + self.appDelegate.myOwnName)
                    
                    self.ref.child("transactions").child("transaction" + String(Int(NSDate().timeIntervalSince1970)) + item + String(j)).setValue(["timestamp": Int(NSDate().timeIntervalSince1970), "borrower": self.assignees[i][j], "lender": self.appDelegate.myOwnName, "amount": splitAmount, "status": "incomplete", "itemName": item])
                }
            }
        }
        self.appDelegate.items.removeAll()
        self.appDelegate.items.append(["item", "price"])
        self.assignees.removeAll()
        self.assignees.append([String]())
        self.ItemTableView.reloadData()
        let confirmMessage = "Split Created"
        let confirmAlertController = UIAlertController(title: "Success", message: confirmMessage, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        confirmAlertController.addAction(confirmAction)
        self.present(confirmAlertController, animated: true, completion: ({
                self.tabBarController?.selectedIndex = 2
            }))
    }
    
    /// Fetches the picked image and uploads it to the server for processing
    ///
    /// - Parameters:
    ///   - picker: The picker manages user interactions and delivers the results of those interactions to a delegate object.
    ///   - info: A dictionary containing the original image and the edited image, if an image was picked; or a filesystem URL for the movie, if a movie was picked.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let receipt = info[UIImagePickerControllerOriginalImage] as! UIImage
        let url = URL(string: "https://api.taggun.io/api/receipt/v1/verbose/file")!
        var request = URLRequest(url: url)
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("dc014900e10411e7a0ebfdc7a5da208a", forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        
        let params = [
            "refresh": "false",
            "incognito": "false"
        ];
        
        request.httpBody = createBody(
            parameters: params,
            boundary: boundary,
            data: UIImageJPEGRepresentation(receipt, 0.5)!,
            mimeType: "image/jpg",
            filename: "receipt.jpg"
        )
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                let errorMessage = "Network Error"
                let errorAlertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                errorAlertController.addAction(dismissAction)
                self.present(errorAlertController, animated: true, completion: nil)
                DispatchQueue.main.async(execute: {
                    self.LoadingIndicator.stopAnimating()
                })
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                var errorMessage = ""
                if (httpStatus.statusCode == 418) {
                    errorMessage = "The image is not a valid receipt or is not legible"
                } else {
                    print(self.convertToDictionary(text: data))
                    errorMessage = "An error occurred"
                }
                let errorAlertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                errorAlertController.addAction(dismissAction)
                self.present(errorAlertController, animated: true, completion: nil)
                DispatchQueue.main.async(execute: {
                    self.LoadingIndicator.stopAnimating()
                })
                return
            }
            
            let result = self.convertToDictionary(text: data)
            let lineAmounts = result["lineAmounts"] as! [AnyObject]
            let totalAmount = (result["totalAmount"] as! [String: Any])["data"] as! Float
//            self.taxAmount = (result["taxAmount"] as! [String: Any])["data"] as! Float
//            self.taxPercentage = self.taxAmount / (totalAmount - self.taxAmount)
            for item in lineAmounts {
                // Append items to cells
                // print(item["description"] as! String)
                // print(self.appDelegate.items.count)
                // Note that indexPath is wrapped in an array:  [indexPath]
                DispatchQueue.main.async(execute: {
                    let row = self.appDelegate.items.count - 1
                    let itemName = item["description"] as! String
                    let itemPrice = String(format: "%@", item["data"] as! NSNumber)
                    self.appDelegate.items[row][0] = itemName
                    self.appDelegate.items[row][1] = itemPrice
                    self.appDelegate.items.append(["item", "price"])
                    self.assignees.append([String]())
                    self.ItemTableView.reloadData()
                })
            }
            DispatchQueue.main.async(execute: {
                self.LoadingIndicator.stopAnimating()
            })
        }
        LoadingIndicator.startAnimating()
        task.resume()
        picker.dismiss(animated: true, completion: nil)
    }
    
    /// Creates the body for the POST request that conforms with the HTTP standard
    ///
    /// - Parameters:
    ///   - parameters: The parameters to add as the form-data
    ///   - boundary: The boundary string which should be generated randomly to separate different parts of the request body
    ///   - data: The file's data to send, in our case the receipt image's data
    ///   - mimeType: The mimeType of the body, in our case it will set to 'image/jpg'
    ///   - filename: The filename of the to-be uploaded receipt image
    /// - Returns: The generated body string encoded as byte stream
    func createBody(parameters: [String: String],
                    boundary: String,
                    data: Data,
                    mimeType: String,
                    filename: String) -> Data {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        
        body.appendString("--\(boundary)--\r\n")
        
        return body as Data
    }
    
    /// Callback when the user cancels the image picking
    ///
    /// - Parameter picker: The picker manages user interactions and delivers the results of those interactions to a delegate object.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    /// Serialize data to dictionary.
    ///
    /// - Parameter text: data
    /// - Returns: dictionary
    func convertToDictionary(text: Data) -> [String: Any] {
        return try! JSONSerialization.jsonObject(with: text, options: []) as! [String: Any]
    }
    
    /// Tells the delegate that the user changed the search text.
    ///
    /// - Parameters:
    ///   - searchBar: The search bar that is being edited
    ///   - searchText: The current text in the search text field
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchResults = []
        if searchText != "" {
            let query = ref.child("users").queryOrdered(byChild: "accountName").queryStarting(atValue: searchText.uppercased()).queryEnding(atValue: searchText.uppercased() + "\u{f8ff}")
            
            query.observeSingleEvent(of: .value, with: { (snapshot) in
                
                for case let childSnapshot as DataSnapshot in snapshot.children {
                    if let data = childSnapshot.value as? [String: Any] {
                        if self.searchResults.contains("\(data["accountName"]!)") {
                            continue
                        }
                        self.searchResults.append("\(data["accountName"]!)")
                    }
                }
            })
        }
       
        let delayInSeconds = 0.3
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            if searchText == "" {
                self.searchResults = []
            }
            
            if (self.searchResults.count > 0) {
                self.SearchTable.isHidden = false
            } else {
                self.SearchTable.isHidden = true
            }
            self.SearchTable.reloadData()
            return
        }
    }
}

extension EventViewController {
    /// Hide keyboard on tap.
    func addHideKeyboardOnTap()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(EventViewController.dismissKeyboard))
        
        self.view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
}

//======================
//related to table view
//======================
extension EventViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// Customize row height.
    ///
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information
    ///   - indexPath: An index path that locates a row in tableView
    /// - Returns: A nonnegative floating-point value that specifies the height (in points) that row should be
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 90.0;//Choose your custom row height
    }

    /// Tells the data source to return the number of rows in a given section of a table view.
    ///
    /// - Parameters:
    ///   - tableView:  The table-view object requesting this information
    ///   - section: An index number identifying a section in tableView
    /// - Returns: The number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int?
        
        if tableView == self.ItemTableView {
            count = self.appDelegate.items.count
        }
        
        if tableView == self.SearchTable {
            count = self.searchResults.count
        }
        print ("count updated: \(count)")
        return count!
    }
    
    /// Tells the delegate that the specified row is now selected.
    ///
    /// - Parameters:
    ///   - tableView: A table-view object informing the delegate about the new row selection
    ///   - indexPath: An index path locating the new selected row in tableView
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.SearchTable {
            self.view.endEditing(true)
            self.SearchTable.isHidden = true
            tableView.deselectRow(at: indexPath, animated: true)
            self.SearchButton.text = ""
            let row = indexPath.row
            if self.appDelegate.people.contains(searchResults[row]) {
                return
            }
            self.appDelegate.people.append(searchResults[row])
            self.PeopleCollectionView.reloadData()
            print("Row: \(row)")
            print(searchResults[row])
        }
    }
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    ///
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell
    ///   - indexPath: An index path locating a row in tableView
    /// - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. An assertion is raised if you return nil.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // your cell coding
        if tableView == self.ItemTableView {
            if (self.appDelegate.items.count - 1 == indexPath.row) {
                let cell = tableView.dequeueReusableCell(withIdentifier: itemCellIdentifier, for: indexPath) as! ItemTableViewCell
                cell.delegate = self
                cell.SplitButton.isHidden = true
                cell.AddButton.isHidden = false
                cell.ItemName.isHidden = true
                cell.ItemPrice.placeholder = "Item Name"
                cell.ItemName.text = ""
                cell.ItemPrice.isHidden = true
                cell.ItemPrice.placeholder = "Item Price"
                cell.ItemPrice.text = ""
                cell.assignees = self.assignees[indexPath.row]
                return cell
            } else if (self.appDelegate.items[indexPath.row][0] == "item") {
                let cell = tableView.dequeueReusableCell(withIdentifier: itemCellIdentifier, for: indexPath) as! ItemTableViewCell
                cell.SplitButton.isHidden = false
                cell.AddButton.isHidden = true
                cell.SplitButton.isHidden = false
                cell.ItemName.isHidden = false
                cell.ItemName.text = ""
                cell.ItemName.placeholder = "Item Name"
                cell.ItemPrice.isHidden = false
                cell.ItemPrice.text = ""
                cell.ItemPrice.placeholder = "Item Price"
                if (self.appDelegate.items[indexPath.row][1] != "price") {
                    cell.ItemPrice.text = self.appDelegate.items[indexPath.row][1]
                }
                cell.assignees = self.assignees[indexPath.row]
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: itemCellIdentifier, for: indexPath) as! ItemTableViewCell
            cell.delegate = self
            cell.AddButton.isHidden = true
            cell.SplitButton.isHidden = false
            cell.ItemName.isHidden = false
            cell.ItemName.placeholder = "Item Name"
            cell.ItemName.text = self.appDelegate.items[indexPath.row][0]
            cell.ItemPrice.isHidden = false
            cell.ItemPrice.text = ""
            cell.ItemPrice.placeholder = "Item Price"
            if (self.appDelegate.items[indexPath.row][1] != "price") {
                cell.ItemPrice.text = self.appDelegate.items[indexPath.row][1]
            }
            cell.ItemPrice.isHidden = false
            cell.assignees = self.assignees[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchTableCell
            if indexPath.row < self.searchResults.count {
                cell.SearchName.text = self.searchResults[indexPath.row].capitalizeSentence(clause: self.searchResults[indexPath.row])
                cell.SearchImage.image = self.appDelegate.getAccountIconFromName(name: cell.SearchName.text!)
            }
            return cell
        }
    }
    
    /// Asks the data source to commit the insertion or deletion of a specified row in the receiver.
    ///
    /// - Parameters:
    ///   - tableView: The table-view object requesting the insertion or deletion
    ///   - editingStyle: The cell editing style corresponding to a insertion or deletion requested for the row specified by indexPath. Possible editing styles are insert or delete.
    ///   - indexPath: An index path locating the row in tableView
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == self.ItemTableView {
            if editingStyle == .delete {
                deleteItemIndexPath = indexPath as NSIndexPath
                confirmDelete()
            }
        }
    }
    
    /// Tells the delegate the table view is about to draw a cell for a particular row.
    ///
    /// - Parameters:
    ///   - tableView: The table-view object informing the delegate of this impending event
    ///   - cell: A table-view cell object that tableView is going to use when drawing the row
    ///   - indexPath: An index path locating the row in tableView
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? ItemTableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: tableViewCell, forRow: indexPath.row)
    }
    
    /// Alert user before an item is deleted.
    func confirmDelete() {
        let alert = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete the item?", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteItem)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteItem)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Update item table after an item is removed.
    ///
    /// - Parameter alertAction: delect action
    func handleDeleteItem(alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteItemIndexPath {
            self.ItemTableView.beginUpdates()
            self.appDelegate.items.remove(at: indexPath.row)
            self.assignees.remove(at: indexPath.row)
            // Note that indexPath is wrapped in an array:  [indexPath]
            self.ItemTableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            deleteItemIndexPath = nil
            self.ItemTableView.endUpdates()
        }
    }
    
    /// Revert action to delete item.
    ///
    /// - Parameter alertAction: UI alert action
    func cancelDeleteItem(alertAction: UIAlertAction!) {
        deleteItemIndexPath = nil
    }
}


//related to Collection view
extension EventViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    /// Asks your data source object for the number of items in the specified section.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - section: An index number identifying a section in collectionView. This index value is 0-based.
    /// - Returns: number of detected devices in the people array if collectionView == PeopleCollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.appDelegate.people.count
        
    }

    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - indexPath: The index path that specifies the location of the item.
    /// - Returns: a peopleCollectionViewCell if collectionView == PeopleCollectionView
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: participantPopIdentifier, for: indexPath) as! PeopleCollectionViewCell
        if indexPath.row < self.appDelegate.people.count {
            let account_name = self.appDelegate.people[indexPath.row].lowercased()
            var nameStringArr = account_name.components(separatedBy: " ")
            cell.accountName.text = nameStringArr[0].capitalizingFirstLetter()
            cell.accountImageView.image = self.appDelegate.getAccountIconFromName(name: account_name)
        }
        return cell
    }
    
    /// Asks your data source object for the number of sections in the collection view.
    ///
    /// - Parameter collectionView: The collection view requesting this information.
    /// - Returns: 1 by default
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    /// Select and de-select people when the item at the specified index path was selected.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change
    ///   - indexPath: The index path of the cell that was selected
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard self.splitable else {
            print("Not splittable")
            return
        }
        
        let person = self.PeopleCollectionView.cellForItem(at: indexPath) as! PeopleCollectionViewCell
        let personName = self.appDelegate.people[indexPath.row]
        
        // toggle color
        person.accountImageView.alpha = (person.accountImageView.alpha == 1) ? 0.5 : 1
        
        // de-select
        if (self.tempAssignees.contains(personName)) {
            print(person.accountName.text! + " is de-selected")
            self.tempAssignees = self.tempAssignees.filter({ $0 != personName })
        }
            // select
        else {
            print(person.accountName.text! + " is selected")
            self.tempAssignees.append(personName)
        }
            
        // DEBUG
        print("Assignees: ")
        for assignee in self.tempAssignees {
            print(assignee + " ")
        }
        
        // Update split button icon
        let buttonIndexPath = IndexPath(row: splitAtIndex, section: 0)
        let item = ItemTableView.cellForRow(at: buttonIndexPath) as! ItemTableViewCell
        if (self.tempAssignees.count > 0) {
            item.SplitButton.setImage(UIImage(named: "correct_people"), for: UIControlState.normal)
        } else {
            item.SplitButton.setImage(UIImage(named: "add_people"), for: UIControlState.normal)
        }
    }
}

//Related to Multipeer API
extension EventViewController : MultipeerManagerDelegate {
    /// handler for detecting a new device and updating people collection view
    ///
    /// - Parameters:
    ///   - manager: MultipeerManager
    ///   - detectedDevice: detected device's user's name
    func deviceDetection(manager : MultipeerManager, detectedDevice: String) {
        if self.appDelegate.people.contains(detectedDevice) {
            return
        }
        self.appDelegate.people.append(detectedDevice)
        self.PeopleCollectionView.reloadData()
    }
    
    /// handler for losing a device and updating people collection view
    ///
    /// - Parameters:
    ///   - manager: MultipeerManager
    ///   - removedDevice: lost device's user's name
    func loseDevice(manager : MultipeerManager, removedDevice: String) {
        if let index = self.appDelegate.people.index(of: removedDevice) {
            self.appDelegate.people.remove(at: index)
        }
        self.PeopleCollectionView.reloadData()
    }
}

extension EventViewController : ItemTableViewCellDelegate {

    /// User clicked split button for an item.
    ///
    /// - Parameter sender: item cel
    func cell_did_add_people(_ sender: ItemTableViewCell) {
        self.view.endEditing(true)
        // Start splitting
        if (self.splitAtIndex != ItemTableView.indexPath(for: sender)?.row) {
            initializeSplitting(cell: sender)
        }
        // End splitting
        else {
            endSplitting(cell: sender)
        }
    }
    
    /// User added a new item.
    ///
    /// - Parameter sender: new item
    func cell_did_add_item(_ sender: ItemTableViewCell) {
        sender.AddButton.isHidden = true
        sender.SplitButton.isHidden = false
        sender.ItemName.placeholder = "Item Name"
        sender.ItemName.text = ""
        sender.ItemName.isHidden = false
        sender.ItemPrice.placeholder = "Item Price"
        sender.ItemPrice.text = ""
        sender.ItemPrice.isHidden = false
        let row = self.appDelegate.items.count
        let indexPath = IndexPath.init(row: row, section: 0)
        self.ItemTableView.beginUpdates()
        self.appDelegate.items.append(["item", "price"])
        self.assignees.append([String]())
        // Note that indexPath is wrapped in an array:  [indexPath]
        self.ItemTableView.insertRows(at: [indexPath as IndexPath], with: .automatic)
        self.ItemTableView.endUpdates()
    }

    /// User updated an item name.
    ///
    /// - Parameters:
    ///   - sender: updated item
    ///   - name: updated name
    func name_cell_did_change(_ sender: ItemTableViewCell, name: String) {
        let index = ItemTableView.indexPath(for: sender)?.row
        self.appDelegate.items[index!][0] = name
    }
    
    /// User updated an item price.
    ///
    /// - Parameters:
    ///   - sender: updated item
    ///   - price: updated price
    func price_cell_did_change(_ sender: ItemTableViewCell, price: String) {
        let index = ItemTableView.indexPath(for: sender)?.row
        self.appDelegate.items[index!][1] = price
    }

    /// Prepare splitting when a split button is clicked.
    ///
    /// - Parameter cell: item to be split
    func initializeSplitting(cell: ItemTableViewCell) {
        // Revert the split button for previous splitting item
        if (splitAtIndex != -1) {
            let buttonIndexPath = IndexPath(row: splitAtIndex, section: 0)
            let item = ItemTableView.cellForRow(at: buttonIndexPath) as! ItemTableViewCell
            item.SplitButton.setImage(UIImage(named: "add_people"), for: UIControlState.normal)
        }
        
        // Initiate a new splitting event
        self.splitAtIndex = (ItemTableView.indexPath(for: cell)?.row)!
        self.splitable = true;
        self.tempAssignees.removeAll()
        for person in self.PeopleCollectionView.visibleCells as! [PeopleCollectionViewCell] {
            let icon = person.accountImageView
            icon?.alpha = 0.5
        }
        self.PeopleCollectionView.allowsMultipleSelection = false
    }
    
    /// Finalize splitting when splitting is done.
    ///
    /// - Parameter cell: item to be split
    func endSplitting(cell: ItemTableViewCell) {
        let index = ItemTableView.indexPath(for: cell)?.row
        self.splitAtIndex = -1
        self.splitable = false
        
        // Save people assignment & revert to original state
        cell.SplitButton.setImage(UIImage(named: "add_people"), for: UIControlState.normal)
        cell.assignees.removeAll()
        cell.assignees.append(contentsOf: self.tempAssignees)
        cell.AssigneeCollection.reloadData()
        self.assignees[index!].removeAll()
        self.assignees[index!].append(contentsOf: self.tempAssignees)
        self.tempAssignees.removeAll()
        for person in PeopleCollectionView.visibleCells as! [PeopleCollectionViewCell] {
            let icon = person.accountImageView
            icon?.alpha = 1
        }
        //self.PeopleCollectionView.allowsMultipleSelection = false
    }
}

extension NSMutableData {
    /// Append strings.
    ///
    /// - Parameter string: input string
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}
