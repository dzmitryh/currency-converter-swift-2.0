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
    
    @IBOutlet weak var baseCurrencyChangeButton: UIButton!
    
    var defaults = {
        return NSUserDefaults.standardUserDefaults()
    }()
    
    var quotes: [String:AnyObject]!
    var decimalDisabled = false
    var enableConversion = false

    var calculator: Calculator

    required init?(coder aDecoder: NSCoder) {
        self.calculator = Calculator()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        makeCurrencyQuoteRequest()
        activityindicator.startAnimating()
        refresh.enabled = false
//        let changeInputCurrencyRecognizer = UITapGestureRecognizer(target: self, action: "handleInputCurrencyChangeTap:")
//        self.changeInputCurrencyLabel.userInteractionEnabled = true
//        self.changeInputCurrencyLabel.addGestureRecognizer(changeInputCurrencyRecognizer)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowCurrencyChange" {
//            let changeCurrencyVC = segue.destinationViewController as? CurrencyPickerViewController
            let navigationVC = segue.destinationViewController as? UINavigationController
            let changeCurrencyVC = navigationVC?.viewControllers.first as? CurrencyPickerViewController
            
//            let changeCurrencyVC = segue.destinationViewController as? CurrencyPickerViewController
            changeCurrencyVC?.quotes = self.quotes.map { Currency(name: "\($0)", rate: "\($1)") }.sort { $0.name < $1.name }
        }
    }
    
    @IBAction func unwindToConvertionController(sender: UIStoryboardSegue) {
        if let bc = (sender.sourceViewController as? CurrencyPickerViewController)?.baseCurrency    {
            self.makeCurrencyQuoteRequest(bc)
        }
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func makeCurrencyQuoteRequest(baseCurrency: String = "USD") {
        self.baseCurrencyChangeButton.setTitle(baseCurrency, forState: .Normal)
        
        CurrencyLayer().requestCurrencyQuotes(baseCurrency) { success, newQuotes, error in
            if success {
                self.quotes = newQuotes
                
                self.removeAllKeysForUserDefaults()
                dispatch_async(dispatch_get_main_queue()) {
                    self.stopActivityIndicator()
                    self.refresh.enabled = true
                }
                self.saveQuotesToUserDefaults(self.quotes)
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.displayAlert("Unable to Retrieve Latest Conversion Rates", message: "\(error) Until then, last used conversion rates apply if available, or else conversion rates will default to rates on July 27, 2015.")
                    self.stopActivityIndicator()
                    self.refresh.enabled = true
                }
                self.quotes = [
                    "EUR": self.accessQuotesFromUserDefaults("EUR"),
                    "USD": self.accessQuotesFromUserDefaults("USD"),
                    "RUB": self.accessQuotesFromUserDefaults("RUB")
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
    
//    func handleInputCurrencyChangeTap(gestureRecognizer: UIGestureRecognizer) {
//        let controller = storyboard?.instantiateViewControllerWithIdentifier("CurrencyPicker") as! CurrencyPickerViewController
//        controller.quotes = self.quotes.map { Currency(name: "\($0)", rate: "\($1)") }
//        self.presentViewController(controller, animated: true, completion: nil)
//    }
    
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
            
        } else if let operationVar = calculator.operation, valueTwo = calculator.secondNumber, valueOne = calculator.firstNumber {
            // do the calculation
            let result = calculator.doCalculation(operationVar, valueOne: valueOne, valueTwo: valueTwo)
            calculator.tempResult = result
            assignInputLableNewValue(result)
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
        eurOutputLabel.text = calculateCurrencyAmount("EUR", plainValue: usdVal)
        gbpOutputLabel.text = calculateCurrencyAmount("USD", plainValue: usdVal)
        inrOutputLabel.text = calculateCurrencyAmount("RUB", plainValue: usdVal)
    }
    
    func calculateCurrencyAmount(quoteKey: String, plainValue: Float) -> String {
        var currencyVal: Float
        if let _ = quotes[quoteKey] {
            currencyVal = plainValue * (quotes[quoteKey] as! Float)
        } else {
            currencyVal = plainValue * 1
        }
        return String(format: "%.2f", currencyVal)
    }
    
}




