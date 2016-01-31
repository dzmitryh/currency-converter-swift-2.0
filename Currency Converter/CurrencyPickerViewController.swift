//
//  CurrencyPickerViewController.swift
//  Currency Converter
//
//  Created by Dzmitry Hubin on 1/29/16.
//  Copyright © 2016 Dzmitry Hubin All rights reserved.
//

import UIKit

class CurrencyPickerViewController: UITableViewController {
    
    var quotes: [Currency]?
    var baseCurrency: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "goBack:")
        self.navigationItem.leftBarButtonItem = backButton

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "exitSegue" {
//            let conversionVC = segue.destinationViewController as? ConversionViewController
            if let cell = sender as? UITableViewCell {
                baseCurrency = (cell.textLabel?.text)!
//                conversionVC?.makeCurrencyQuoteRequest()
            }
        }
    }
    
    func goBack(sender:UIButton) {
        //Initiate newViewController this way
//        let conversionVC = self.storyboard?.instantiateViewControllerWithIdentifier("ConversionController") as?
//        let conversionVC = self.storyboard?.("ConversionController") as?         ConversionViewController
//        self.navigationController?.pushViewController(conversionVC!, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
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
        super.viewDidAppear(animated)
    }
    
}
