//
//  ConversionDetailViewController.swift
//  Currency Converter
//
//  Created by Mayank Kumar on 7/30/15.
//  Copyright (c) 2015 Mayank Kumar. All rights reserved.
//

import UIKit
import CoreData

class ConversionDetailViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var usdValue: UILabel!
    @IBOutlet var editField: UITextField!
    var context: NSManagedObjectContext!
    var managedObject: Conversion!
    var usdVal: String!
    var initialText: String!
    
    override func viewWillAppear(animated: Bool) {
        editField.delegate = self
        usdValue.text = usdVal
        editField.text = initialText
    }
    
    @IBAction func saveChanges(sender: UIButton) {
        var saveText = editField.text
        if editField.text == "" {
            saveText = "0"
        }
        managedObject.association = saveText!
        do {
            try context.save()
        } catch _ {
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cancelChanges(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func deleteConversion(sender: UIButton) {
        context.deleteObject(managedObject)
        do {
            try context.save()
        } catch _ {
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
}
