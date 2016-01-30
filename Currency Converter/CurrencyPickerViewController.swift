//
//  CurrencyPickerViewController.swift
//  Currency Converter
//
//  Created by Dzmitry Hubin on 1/29/16.
//  Copyright © 2016 Dzmitry Hubin All rights reserved.
//

import UIKit

//extension Dictionary {
//    subscript(i:Int) -> (key:Key,value:Value) {
//        get {
//            return self[self.startIndex.advancedBy(i)]
//        }
//    }
//}

class CurrencyPickerViewController: UITableViewController {
    
//    @IBOutlet weak var currencyPlaceholder: UILabel!
    var quotes: [Currency]?
    
//    @IBOutlet weak var goBackButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func buttonMethod() {
        print("Perform action")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (quotes?.count)!
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CurrencyCell", forIndexPath: indexPath)
        if let quotesArr = quotes {
            cell.textLabel?.text = quotesArr[indexPath.row].name
        }
        return cell
    }
    
    override func viewDidAppear(animated: Bool) {
        let camera = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: Selector("btnOpenCamera"))
        self.navigationItem.rightBarButtonItem = camera
    }
    

}
