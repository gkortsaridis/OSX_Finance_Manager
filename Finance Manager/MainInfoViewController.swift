//
//  MainInfoViewController.swift
//  Finance Manager
//
//  Created by George Kortsaridis on 27/04/2019.
//  Copyright © 2019 George Kortsaridis. All rights reserved.
//

import Cocoa
import Alamofire

class MainInfoViewController: NSViewController {

    var selectedAccount = 0
    @IBOutlet weak var accountsTableView: NSTableView!
    @IBOutlet weak var transactionsTableView: NSTableView!
    @IBOutlet weak var transactionsLoading: NSProgressIndicator!
    var accountsInfoTxt:String = ""
    var accountsJson:([Dictionary<String, Any>])? = nil
    var transactionsJson:([Dictionary<String, Any>])? = nil
    var accountForSettings: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountsTableView.delegate = self
        accountsTableView.dataSource = self
        accountsTableView.rowHeight = 70
        
        transactionsTableView.delegate = self
        transactionsTableView.dataSource = self
        transactionsTableView.rowHeight = 70
        
        accountsInfoTxt = AppDelegate.accountsInfo
        
        let data: Data? = (accountsInfoTxt).data(using: .utf8)
        do {
            if let json = try JSONSerialization.jsonObject(with: data!, options : .allowFragments) as? [Dictionary<String,Any>] {
                //print(accountsJson) // use the json here
                accountsJson = json
                accountsTableView.reloadData()
                accountsTableView.selectRowIndexes([0], byExtendingSelection: true)
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func getTransactions(url: String){
        self.transactionsLoading.startAnimation(nil)
        let token = "Bearer ZHPR5AU2NEWYUVKBRF4TWNSRFJV2RZEPCIYGRDY2VMI7ABBF4QDSE4NFODYIYP43"
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Accept": "application/json"
        ]
        Alamofire.request(url, headers:headers).responseJSON { response in
            if let json = response.result.value {
                self.transactionsLoading.stopAnimation(nil)
                self.transactionsJson = (json as! ([Dictionary<String, Any>]))
                self.transactionsTableView.reloadData()
            }
        }

    }

    @IBAction func goToSettings(_ sender: Any) {
        
        if let myViewController = self.storyboard?.instantiateController(withIdentifier: "Settings") as? SettingsViewController {
            self.view.window?.contentViewController = myViewController
        }
    }
    
    @objc func goToAccountSettings(_ sender: Any){
        if let myViewController = self.storyboard?.instantiateController(withIdentifier: "accountSettings") as? AccountSettingsViewController {
            myViewController.accountJson = accountsJson![(sender as AnyObject).tag!]
            self.view.window?.contentViewController = myViewController
        }
    }
    
}

extension MainInfoViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if(tableView.identifier!.rawValue == "accountsTableView"){
            return accountsJson?.count ?? 0
        }else if(tableView.identifier!.rawValue == "transactionsTableView"){
            return transactionsJson?.count ?? 0
        }
        
        return 1
    }
}

extension MainInfoViewController: NSTableViewDelegate {
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let table = notification.object as! NSTableView
        if(table.identifier!.rawValue == "accountsTableView"){
            selectedAccount = table.selectedRow
            let links = accountsJson![selectedAccount]["links"] as! Dictionary<String, Any>
            getTransactions(url: links["transactions"] as! String)
        }else{
            
        }
    }
   
    
    fileprivate enum CellIdentifiers {
        static let AccountCell = "accountsCell"
        static let TransactionCell = "transactionCell"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellIdentifier: String = ""

        if(tableView.identifier!.rawValue == "accountsTableView"){
            var name: String = ""
            var amount: String = ""
            var currency: String = ""
            // 1
            guard let item = accountsJson?[row] else {
                return nil
            }
            
            // 2
            if tableColumn == tableView.tableColumns[0] {
                
                let defaults = UserDefaults.standard
                let savedName = defaults.string(forKey: item["id"] as! String)
                if(savedName != nil){
                    name = savedName!
                }else{
                    name = item["name"] as! String
                }
                amount = item["balance"] as! String
                currency = item["currency"] as! String
                if(currency == "GBP"){ currency = "£" }
                else if(currency == "EUR"){ currency = "€" }
                if(currency == "USD"){ currency = "$" }
                cellIdentifier = CellIdentifiers.AccountCell
            }
            
            // 3
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? AccountsTableCellView {
                cell.accountName?.stringValue = name
                cell.accountAmount?.stringValue = amount+" "+currency
                cell.accountSettings.tag = row
                cell.accountSettings.action = #selector(goToAccountSettings(_:))
                return cell
            }
        }else{
            var description: String = ""
            var amount: String = ""
            var date: String = ""
            
            // 1
            guard let item = transactionsJson?[row] else {
                return nil
            }
            
            // 2
            cellIdentifier = CellIdentifiers.TransactionCell
            description = item["description"] as! String
            amount = item["amount"] as! String
            date = item["date"] as! String
            
            // 3
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? TransactionsTableCellView {
                cell.transactionAmount.stringValue = amount
                cell.transactionTime.stringValue = date
                cell.transactionDescription.stringValue = description
                return cell
            }
        }
        
        return nil
    }
    
    
}

class AccountsTableCellView: NSTableCellView {
    @IBOutlet weak var accountName: NSTextField!
    @IBOutlet weak var accountAmount: NSTextField!
    @IBOutlet weak var accountSettings: NSButton!
}

class TransactionsTableCellView: NSTableCellView{
    @IBOutlet weak var transactionDescription: NSTextField!
    @IBOutlet weak var transactionTime: NSTextField!
    @IBOutlet weak var transactionAmount: NSTextField!
}

extension MainInfoViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> MainInfoViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let myViewController = storyboard.instantiateController(withIdentifier: "MainInfo") as? MainInfoViewController {
            return myViewController
        }else{
            fatalError("Why cant i find QuotesViewController? - Check Main.storyboard")
        }
       
    }
}
