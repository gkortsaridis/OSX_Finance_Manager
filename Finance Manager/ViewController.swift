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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        Alamofire.request(url, headers:headers).responseJSON { response in
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
                openMainInfo(json)
            }
        }
        
    }
    
    
    func openMainInfo(json: Any){
        let mainInfoVC : MainInfoViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainInfo") as! MainInfoViewController
        
        mainInfoVC.accountsInfoTxt = json
        self.present(mainInfoVC, animated: true, completion: nil)
    }
    
}

