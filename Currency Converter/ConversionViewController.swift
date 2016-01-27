//
//  ViewController.swift
//  Currency Converter
//
//  Created by Dzmitry Hubin on 1/27/16.
//
//  Copyright (c) 2015 Dzmitry Hubin. All rights reserved.
//

import UIKit

class ConversionViewController: UIViewController {
    
    @IBOutlet var refresh: UIButton!
    @IBOutlet var activityindicator: UIActivityIndicatorView!
    
    @IBOutlet weak var divisionButton: UIButton!
    @IBOutlet weak var multiplicationButton: UIButton!
    @IBOutlet weak var subtractionButton: UIButton!
    @IBOutlet weak var additionButton: UIButton!
    @IBOutlet var operators: [UIButton]?
    
    
    @IBOutlet var usdInputLabel: UILabel!
    @IBOutlet var eurOutputLabel: UILabel!
    @IBOutlet var gbpOutputLabel: UILabel!
    @IBOutlet var inrOutputLabel: UILabel!
    
    var defaults = {
        return NSUserDefaults.standardUserDefaults()
    }()
    
    enum Operator {
        case Plus
        case Minus
        case Multiply
        case Divide
    }

    var quotes: [String:AnyObject]!
    var decimalDisabled = false
    var enableConversion = false
    
    var firstNumber: Float?
    var secondNumber:Float?
    var tempResult: Float?
    var operation: Operator?
    
    override func viewDidLoad() {
        makeCurrencyQuoteRequest()
        activityindicator.startAnimating()
        refresh.enabled = false
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func makeCurrencyQuoteRequest() {
        CurrencyLayer().requestCurrencyQuotes() { success, newQuotes, error in
            if success {
                self.quotes = newQuotes
                
                self.removeAllKeysForUserDefaults()
                dispatch_async(dispatch_get_main_queue()) {
                    self.stopActivityIndicator()
                    self.refresh.enabled = true
                }
                
                //Persist quotes using NSUserDefaults
                self.saveQuotesToUserDefaults(self.quotes["USDEUR"] as! Float, key: "EUR")
                self.saveQuotesToUserDefaults(self.quotes["USDGBP"] as! Float, key: "GBP")
                self.saveQuotesToUserDefaults(self.quotes["USDINR"] as! Float, key: "INR")
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.displayAlert("Unable to Retrieve Latest Conversion Rates", message: "\(error) Until then, last used conversion rates apply if available, or else conversion rates will default to rates on July 27, 2015.")
                    self.stopActivityIndicator()
                    self.refresh.enabled = true
                }
                self.quotes = [
                    "USDEUR": self.accessQuotesFromUserDefaults("EUR"),
                    "USDGBP": self.accessQuotesFromUserDefaults("GBP"),
                    "USDINR": self.accessQuotesFromUserDefaults("INR")
                ]
            }
            self.enableConversion = true
        }
    }
    
    func stopActivityIndicator() {
        self.activityindicator.stopAnimating()
        self.activityindicator.hidden = true
    }
    
    func saveQuotesToUserDefaults(value: Float, key: String) {
        defaults.setFloat(value, forKey: key)
    }
    
    func removeAllKeysForUserDefaults() {
        defaults.removeObjectForKey("EUR")
        defaults.removeObjectForKey("GBP")
        defaults.removeObjectForKey("INR")
    }
    
    func accessQuotesFromUserDefaults(key: String) -> Float {
        let quote = defaults.floatForKey(key)
        if quote != 0 {
            return quote
        }
        else {
            switch(key) {
                case "GBP": return 0.6427
                
                case "EUR": return 0.902
                
                case "INR": return 64.2234
                
                default: return 0
            }
        }
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        
        if enableConversion {
            
            if usdInputLabel.text == "0" {
                
                usdInputLabel.text = sender.titleLabel!.text!
                
                if operation == nil {
                    firstNumber = (usdInputLabel.text! as NSString).floatValue
                } else {
                    secondNumber = (usdInputLabel.text! as NSString).floatValue
                }
                
            } else {
                
                if operation == nil {
                    usdInputLabel.text = "\(usdInputLabel.text!)\(sender.titleLabel!.text!)"
                    firstNumber = (usdInputLabel.text! as NSString).floatValue
                    
                } else if tempResult != nil || secondNumber == nil {
                    usdInputLabel.text = sender.titleLabel!.text!
                    secondNumber = (usdInputLabel.text! as NSString).floatValue
                    
                } else {
                    usdInputLabel.text = "\(usdInputLabel.text!)\(sender.titleLabel!.text!)"
                    secondNumber = (usdInputLabel.text! as NSString).floatValue
                }
                
            }

        } else {
            displayAlert("Currently Downloading New Rates", message: "Please wait a moment before initating any conversion.")
            if sender.titleLabel?.text == "." {
                decimalDisabled = false
            }
        }
        
    }
    
    @IBAction func disableDecimalOnFirstUse(sender: UIButton) {
        if !decimalDisabled {
            decimalDisabled = true
            appendDigit(sender)
        }
        else {
            displayAlert("Invalid Decimal Point Insertion", message: "Adding another decimal would make the USD value invalid.")
        }
    }
    
    @IBAction func allClear(sender: UIButton) {
        if enableConversion {
            usdInputLabel.text = "0"
            decimalDisabled = false
            convertToCurrencies()
        }
        clearOperatorButtonBorders()
        operation = nil
        firstNumber = nil
        secondNumber = nil
        tempResult = nil
        
    }
    
    @IBAction func deleteValue(sender: UIButton) {
        if enableConversion {
            if (usdInputLabel.text!).characters.count == 1 {
                allClear(sender)
                decimalDisabled = false
                return
            }
            if usdInputLabel.text == "0" {
                displayAlert("Unable to Delete", message: "There is nothing to delete.")
            }
            else {
                let index = usdInputLabel.text?.endIndex.predecessor()
                let lastChar = usdInputLabel.text!.removeAtIndex(index!)
                if lastChar == "." {
                    decimalDisabled = false
                }
            }
        }
        else {
            displayAlert("Currently Downloading New Rates", message: "Please wait a moment before initating any conversion.")
        }
    }
        
    
    
    @IBAction func saveConversion(sender: UIButton) {
        if usdInputLabel.text != "0" {
            let controller = storyboard?.instantiateViewControllerWithIdentifier("AssociationView") as! AssociationViewController
            controller.baseVal = convertStringToFloat(usdInputLabel.text!)
            controller.eurVal = convertStringToFloat(eurOutputLabel.text!)
            controller.gbpVal = convertStringToFloat(gbpOutputLabel.text!)
            controller.inrVal = convertStringToFloat(inrOutputLabel.text!)
            self.presentViewController(controller, animated: true, completion: nil)
        }
        else {
            displayAlert("No Conversion Made", message: "You cannot save because you have not made a conversion.")
        }
    }
    
    @IBAction func refreshRates(sender: UIButton) {
        makeCurrencyQuoteRequest()
        activityindicator.hidden = false
        activityindicator.startAnimating()
        refresh.enabled = false
    }
    
    @IBAction func doConvert(sender: AnyObject) {
        convertToCurrencies()
    }
    
    @IBAction func setDivision(sender: AnyObject) {
        clearOperatorButtonBorders()
        highlightButtonBorder(sender)
        operation = .Divide
    }
    
    @IBAction func setMultiplication(sender: AnyObject) {
        clearOperatorButtonBorders()
        highlightButtonBorder(sender)
        operation = .Multiply
    }
    
    @IBAction func setSubtraction(sender: AnyObject) {
        clearOperatorButtonBorders()
        highlightButtonBorder(sender)
        operation = .Minus
    }
    
    @IBAction func setAddition(sender: AnyObject) {
        clearOperatorButtonBorders()
        highlightButtonBorder(sender)
        operation = .Plus    }
    
    @IBAction func calculateResult(sender: AnyObject) {
        clearOperatorButtonBorders()
        
        if let tempResultVar = tempResult, operationVar = operation, valueTwo = secondNumber, var valueOne = firstNumber {
            
            valueOne = tempResultVar
            // do the calculation
            doCalculation(operationVar, valueOne: valueOne, valueTwo: valueTwo)
            
        } else if let operationVar = operation, valueTwo = secondNumber, valueOne = firstNumber {
            // do the calculation
            doCalculation(operationVar, valueOne: valueOne, valueTwo: valueTwo)
        }
    }
    
    func doCalculation(operation: Operator, valueOne: Float, valueTwo: Float) {
       
        let res: Float;
        
        switch operation {
            
        case Operator.Plus:
            res = valueOne + valueTwo
            
        case Operator.Minus:
            res = valueOne - valueTwo
            
        case Operator.Multiply:
            res = valueOne * valueTwo
            
        case Operator.Divide:
            res = valueOne / valueTwo
            
        }
        
        tempResult = res
        
        if res % 1 != 0 {
            usdInputLabel.text = res.description
        } else {
            usdInputLabel.text = String(format: "%.0f", res)
        }
        
    }
    
    func clearOperatorButtonBorders() {
        guard let calcOperators = operators else {
            print("calculator operators aren't in place!")
            return
        }
        
        for calcOperator in calcOperators {
            calcOperator.layer.borderWidth = 0
        }
    }
    
    func highlightButtonBorder(sender: AnyObject) {
        sender.layer.borderWidth = 2.0
        sender.layer.borderColor = UIColor.grayColor().CGColor
    }
    
    func convertStringToFloat(string: String) -> Float {
        return (string as NSString).floatValue
    }
    
    func convertToCurrencies() {
        let usdVal = (usdInputLabel.text! as NSString).floatValue
        let euroVal = usdVal * (quotes["USDEUR"] as! Float)
        eurOutputLabel.text = String(format: "%.2f", euroVal)
        
        let gbpVal = usdVal * (quotes["USDGBP"] as! Float)
        gbpOutputLabel.text = String(format: "%.2f", gbpVal)
        
        let inrVal = usdVal * (quotes["USDINR"] as! Float)
        inrOutputLabel.text = String(format: "%.2f", inrVal)
    }
    
    
}




