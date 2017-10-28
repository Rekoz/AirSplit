//
//  ViewController.swift
//  Drop
//
//  Created by Camille Zhang on 10/18/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var username_input: UITextField!
    @IBOutlet var passowrd_input: UITextField!
    @IBOutlet var login_button: UIButton!
    
    @IBAction func loginDidTouch(_ sender: AnyObject) {
 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

