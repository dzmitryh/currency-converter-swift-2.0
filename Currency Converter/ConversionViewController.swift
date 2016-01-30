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
    
//    @IBOutlet weak var changeInputCurrencyLabel: UILabel!
    
    var defaults = {
        return NSUserDefaults.standardUserDefaults()
    }()
    
    var quotes: [String:AnyObject]!
    var decimalDisabled = false
    var enableConversion = false

    var calculator: Calculator
    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//        self.calculator = Calculator()
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }

    required init?(coder aDecoder: NSCoder) {
        self.calculator = Calculator()
        super.init(coder: aDecoder)
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        makeCurrencyQuoteRequest()
        activityindicator.startAnimating()
        refresh.enabled = false
//        let changeInputCurrencyRecognizer = UITapGestureRecognizer(target: self, action: "handleInputCurrencyChangeTap:")
//        self.changeInputCurrencyLabel.userInteractionEnabled = true
//        self.changeInputCurrencyLabel.addGestureRecognizer(changeInputCurrencyRecognizer)
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
                //TODO
//                self.saveQuotesToUserDefaults(self.quotes["USDEUR"] as! Float, key: "EUR")
//                self.saveQuotesToUserDefaults(self.quotes["USDGBP"] as! Float, key: "GBP")
//                self.saveQuotesToUserDefaults(self.quotes["USDINR"] as! Float, key: "INR")
                
//                self.saveQuotesToUserDefaults(self.quotes["EUR"] as! Float, key: "EUR")
//                self.saveQuotesToUserDefaults(self.quotes["USD"] as! Float, key: "USD")
//                self.saveQuotesToUserDefaults(self.quotes["RUB"] as! Float, key: "RUB")
                self.saveQuotesToUserDefaults(self.quotes)
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.displayAlert("Unable to Retrieve Latest Conversion Rates", message: "\(error) Until then, last used conversion rates apply if available, or else conversion rates will default to rates on July 27, 2015.")
                    self.stopActivityIndicator()
                    self.refresh.enabled = true
                }
                self.quotes = [
                    //TODO
//                    "USDEUR": self.accessQuotesFromUserDefaults("EUR"),
//                    "USDGBP": self.accessQuotesFromUserDefaults("GBP"),
//                    "USDINR": self.accessQuotesFromUserDefaults("INR")
                    "BRLEUR": self.accessQuotesFromUserDefaults("EUR"),
                    "BRLUSD": self.accessQuotesFromUserDefaults("USD"),
                    "BRLRUB": self.accessQuotesFromUserDefaults("RUB")
                ]
            }
            self.enableConversion = true
        }
    }
    
    func stopActivityIndicator() {
        self.activityindicator.stopAnimating()
        self.activityindicator.hidden = true
    }
    
//    func saveQuotesToUserDefaults(value: Float, key: String) {
    func saveQuotesToUserDefaults(quotes: [String:AnyObject]) {
//        defaults.setFloat(value, forKey: key)
        defaults.registerDefaults(quotes)
    }
    
    func removeAllKeysForUserDefaults() {
        //TODO
//        defaults.removeObjectForKey("EUR")
//        defaults.removeObjectForKey("GBP")
//        defaults.removeObjectForKey("INR")

        defaults.removeObjectForKey("EUR")
        defaults.removeObjectForKey("USD")
        defaults.removeObjectForKey("RUB")

    }
    
    func accessQuotesFromUserDefaults(key: String) -> Float {
        let quote = defaults.floatForKey(key)
        if quote != 0 {
            return quote
        }
        else {
            switch(key) {
                //TODO
//                case "GBP": return 0.6427
//                
//                case "EUR": return 0.902
//                
//                case "INR": return 64.2234
                
                case "EUR": return 0.2249
                    
                case "USD": return 0.24372
                    
                case "RUB": return 19.515
                
                default: return 0
            }
        }
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        
        if enableConversion {
            
            if usdInputLabel.text == "0" {
                
                usdInputLabel.text = sender.titleLabel!.text!
                
                if calculator.operation == nil {
                    calculator.firstNumber = (usdInputLabel.text! as NSString).floatValue
                } else {
                    calculator.secondNumber = (usdInputLabel.text! as NSString).floatValue
                }
                
            } else {
                
                if calculator.operation == nil {
                    usdInputLabel.text = "\(usdInputLabel.text!)\(sender.titleLabel!.text!)"
                    calculator.firstNumber = (usdInputLabel.text! as NSString).floatValue
                    
                } else if calculator.tempResult != nil || calculator.secondNumber == nil {
                    usdInputLabel.text = sender.titleLabel!.text!
                    calculator.secondNumber = (usdInputLabel.text! as NSString).floatValue
                    
                } else {
                    usdInputLabel.text = "\(usdInputLabel.text!)\(sender.titleLabel!.text!)"
                    calculator.secondNumber = (usdInputLabel.text! as NSString).floatValue
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
        calculator.operation = nil
        calculator.firstNumber = nil
        calculator.secondNumber = nil
        calculator.tempResult = nil
        
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
    
    func handleInputCurrencyChangeTap(gestureRecognizer: UIGestureRecognizer) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewControllerWithIdentifier("next")
//        self.presentViewController(vc, animated: true, completion: nil)
        print("change currency label has been clicked!")
        let controller = storyboard?.instantiateViewControllerWithIdentifier("CurrencyPicker") as! CurrencyPickerViewController
//        controller.quotes = self.quotes
        
//        var currencyArr = [Currency]()
//        for (key, value) in self.quotes {
//            currencyArr.append(Currency(name: key, rate: value))
//        }
        
        controller.quotes = self.quotes.map { Currency(name: "\($0)", rate: "\($1)") }
        self.presentViewController(controller, animated: true, completion: nil)
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
        calculator.operation = .Divide
    }
    
    @IBAction func setMultiplication(sender: AnyObject) {
        clearOperatorButtonBorders()
        highlightButtonBorder(sender)
        calculator.operation = .Multiply
    }
    
    @IBAction func setSubtraction(sender: AnyObject) {
        clearOperatorButtonBorders()
        highlightButtonBorder(sender)
        calculator.operation = .Minus
    }
    
    @IBAction func setAddition(sender: AnyObject) {
        clearOperatorButtonBorders()
        highlightButtonBorder(sender)
        calculator.operation = .Plus
    }
    
    @IBAction func calculateResult(sender: AnyObject) {
        clearOperatorButtonBorders()
        
        if let tempResultVar = calculator.tempResult, operationVar = calculator.operation, valueTwo = calculator.secondNumber, var valueOne = calculator.firstNumber {
            
            valueOne = tempResultVar
            // do the calculation
            let result = calculator.doCalculation(operationVar, valueOne: valueOne, valueTwo: valueTwo)
            calculator.tempResult = result
            assignInputLableNewValue(result)
//            doCalculation(operationVar, valueOne: valueOne, valueTwo: valueTwo)
            
        } else if let operationVar = calculator.operation, valueTwo = calculator.secondNumber, valueOne = calculator.firstNumber {
            // do the calculation
            let result = calculator.doCalculation(operationVar, valueOne: valueOne, valueTwo: valueTwo)
            calculator.tempResult = result
            assignInputLableNewValue(result)
//            doCalculation(operationVar, valueOne: valueOne, valueTwo: valueTwo)
        }
    }
    
    func assignInputLableNewValue(result: Float) {
        if result % 1 != 0 {
            usdInputLabel.text = result.description
        } else {
            usdInputLabel.text = String(format: "%.0f", result)
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
//        let euroVal = usdVal * (quotes["USDEUR"] as! Float)
        let euroVal = usdVal * (quotes["EUR"] as! Float)
        eurOutputLabel.text = String(format: "%.2f", euroVal)
        
//        let gbpVal = usdVal * (quotes["USDGBP"] as! Float)
//        let gbpVal = usdVal * (quotes["USD"] as! Float)
//        gbpOutputLabel.text = String(format: "%.2f", gbpVal)
        
//        let inrVal = usdVal * (quotes["USDINR"] as! Float)
        let inrVal = usdVal * (quotes["RUB"] as! Float)
        inrOutputLabel.text = String(format: "%.2f", inrVal)
    }
    
}




