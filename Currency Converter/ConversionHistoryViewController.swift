//
//  ConversionHistoryViewController.swift
//  Currency Converter
//
//  Created by Mayank Kumar on 7/29/15.
//  Copyright (c) 2015 Mayank Kumar. All rights reserved.
//

import UIKit
import CoreData

class ConversionHistoryViewController: UITableViewController {
    
    @IBOutlet var tempView: UIView!
    var appDel: AppDelegate  {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    var sharedContext: NSManagedObjectContext {
        return appDel.managedObjectContext!
    }
    
    var fetchedConversions: [Conversion]!
    
    override func viewWillAppear(animated: Bool) {
        fetchedConversions = fetchAllConversions()
        if fetchedConversions.count == 0 {
            self.tableView.tableFooterView = tempView
        }
        else {
            self.tableView.tableFooterView = UIView()
        }
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! ConversionCell
        let controller = segue.destinationViewController as! ConversionDetailViewController
        controller.usdVal = cell.usdValue.text!
        controller.initialText = cell.associations.text!
        controller.context = sharedContext
        controller.managedObject = fetchedConversions[(tableView.indexPathForCell(cell)?.row)!]
    }
    
    func fetchAllConversions() -> [Conversion]! {
        let request = NSFetchRequest(entityName: "Conversion")
        var results: [Conversion]!
        do {
            results = try sharedContext.executeFetchRequest(request) as! [Conversion]
        } catch {
            results = nil
        }
        return results
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! ConversionCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: ConversionCell, indexPath: NSIndexPath) {
        cell.usdValue.text = "\(fetchedConversions[indexPath.row].baseValue)"
        cell.euroLabel.text = "\(fetchedConversions[indexPath.row].eurValue)"
        cell.poundLabel.text = "\(fetchedConversions[indexPath.row].gbpValue)"
        cell.rupeeLabel.text = "\(fetchedConversions[indexPath.row].inrValue)"
        var association = fetchedConversions[indexPath.row].association
        if association == "0" {
            association = "None"
        }
        cell.associations.text = association
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetchedConversions == nil {
            return 0
        }
        return fetchedConversions.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}