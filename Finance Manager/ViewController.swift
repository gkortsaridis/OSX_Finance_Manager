//
//  ViewController.swift
//  Finance Manager
//
//  Created by George Kortsaridis on 27/04/2019.
//  Copyright © 2019 George Kortsaridis. All rights reserved.
//

import Cocoa
import Alamofire

class ViewController: NSViewController {

    @IBOutlet weak var tellerApiInput: NSTextField!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    @IBOutlet weak var saveToken: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "token")
        if(token != nil){
            tellerApiInput.stringValue = token!
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func connectTeller(_ sender: Any) {
        let token = "Bearer "+tellerApiInput.stringValue
        let url = "https://api.teller.io/accounts"
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Accept": "application/json"
        ]
        self.loadingIndicator.startAnimation(nil)

        Alamofire.request(url, headers:headers).responseString { response in
            if let json = response.result.value {
                //print("JSON: \(json)") // serialized json response
                self.loadingIndicator.stopAnimation(nil)

                if(self.saveToken.state.rawValue == 1){
                    let defaults = UserDefaults.standard
                    defaults.set(self.tellerApiInput.stringValue, forKey: "token")
                }
                
                if let myViewController = self.storyboard?.instantiateController(withIdentifier: "MainInfo") as? MainInfoViewController {
                    AppDelegate.accountsInfo = json
                    self.view.window?.contentViewController = myViewController
                    AppDelegate.loggedIn = true
                }
            }
        }
        
    }
    
}

extension ViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> ViewController {
        //1.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        //2.
        let identifier = "ViewController"
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? ViewController else {
            fatalError("Why cant i find QuotesViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
