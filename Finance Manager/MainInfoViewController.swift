//
//  MainInfoViewController.swift
//  Finance Manager
//
//  Created by George Kortsaridis on 27/04/2019.
//  Copyright © 2019 George Kortsaridis. All rights reserved.
//

import Cocoa

class MainInfoViewController: NSViewController {

    var selectedAccount = 0
    @IBOutlet weak var accountsTableView: NSTableView!
    var accountsInfoTxt:String = ""
    var accountsJson:([Dictionary<String, Any>])? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountsTableView.delegate = self
        accountsTableView.dataSource = self
        accountsTableView.rowHeight = 112


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

}

extension MainInfoViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return accountsJson?.count ?? 0
    }
    
   
}

extension MainInfoViewController: NSTableViewDelegate {
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let table = notification.object as! NSTableView
        selectedAccount = table.selectedRow
    }
   
    
    fileprivate enum CellIdentifiers {
        static let AccountCell = "accountsCell"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var name: String = ""
        var amount: String = ""
        var cellIdentifier: String = ""
        var currency: String = ""
        var bank: String = ""
        var bankImg: NSImage = NSImage(named:"bank")!
        // 1
        guard let item = accountsJson?[row] else {
            return nil
        }
        
        // 2
        if tableColumn == tableView.tableColumns[0] {
            name = item["name"] as! String
            amount = item["balance"] as! String
            currency = item["currency"] as! String
            if(currency == "GBP"){ currency = "£" }
            else if(currency == "EUR"){ currency = "€" }
            if(currency == "USD"){ currency = "$" }
            bank = item["institution"] as! String
            if(bank.lowercased() == "hsbc"){ bankImg = NSImage(named: "hsbc")! }
            cellIdentifier = CellIdentifiers.AccountCell
        }
        
        // 3
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? AccountsTableCellView {
            cell.accountName?.stringValue = name
            cell.accountAmount?.stringValue = amount+" "+currency
            cell.accountBankIcon?.image = bankImg
            return cell
        }
        return nil
    }
    
    
}

class AccountsTableCellView: NSTableCellView {
    @IBOutlet weak var accountName: NSTextField!
    @IBOutlet weak var accountAmount: NSTextField!
    @IBOutlet weak var accountBankIcon: NSImageView!
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
