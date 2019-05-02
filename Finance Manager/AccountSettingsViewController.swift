//
//  AccountSettingsViewController.swift
//  Finance Manager
//
//  Created by George Kortsaridis on 02/05/2019.
//  Copyright © 2019 George Kortsaridis. All rights reserved.
//

import Cocoa

class AccountSettingsViewController: NSViewController {

    @IBOutlet weak var accountName: NSTextField!
    var accountJson:(Dictionary<String, Any>)? = nil
    var accountId: String? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        //print(accountJson)
        accountName.stringValue = accountJson!["name"] as! String
        accountId = accountJson!["id"] as? String
    }
    
    @IBAction func backHome(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.set(accountName.stringValue, forKey: accountId!)
        
        if let myViewController = self.storyboard?.instantiateController(withIdentifier: "MainInfo") as? MainInfoViewController {
            self.view.window?.contentViewController = myViewController
        }
    }
}
