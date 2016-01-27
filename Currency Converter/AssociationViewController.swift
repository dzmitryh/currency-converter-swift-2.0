//
//  AssociationViewController.swift
//  Currency Converter
//
//  Created by Dzmitry Hubin on 1/27/16.
//
//  Copyright (c) 2015 Dzmitry Hubin. All rights reserved.
//

import UIKit
import CoreData

class AssociationViewController: UIViewController, UITextFieldDelegate {
    
    var baseVal: Float!
    var eurVal: Float!
    var gbpVal: Float!
    var inrVal: Float!
    var association: String!
    var appDel: AppDelegate  {
       return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    var sharedContext: NSManagedObjectContext {
        return appDel.managedObjectContext!
    }
    
    @IBOutlet var associationField: UITextField!
    
    override func viewDidLoad() {
        associationField.delegate = self
    }
    
    @IBAction func saveConversion(sender: UIButton) {
        association = associationField.text
        if association == "" {
            association = "0"
        }
        let dictionary = [
            "baseVal": baseVal,
            "eurVal": eurVal,
            "gbpVal": gbpVal,
            "inrVal": inrVal,
            "association": association
        ]
        _ = Conversion(dictionary: dictionary as! [String : AnyObject], context: sharedContext)
        appDel.saveContext()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func cancelSave(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
}