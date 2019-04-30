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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.isHidden = true
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func connectTeller(_ sender: Any) {

        print(tellerApiInput.debugDescription)
        let token = "Bearer ZHPR5AU2NEWYUVKBRF4TWNSRFJV2RZEPCIYGRDY2VMI7ABBF4QDSE4NFODYIYP43"
        let url = "https://api.teller.io/accounts"
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Accept": "application/json"
        ]
        loadingIndicator.isHidden = false

        Alamofire.request(url, headers:headers).responseString { response in
            if let json = response.result.value {
                //print("JSON: \(json)") // serialized json response
                self.loadingIndicator.isHidden = true

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
