//
//  CurrencyLayer.swift

//  Currency Converter
//
//  Created by Dzmitry Hubin on 1/27/16.
//
//  Copyright (c) 2015 Dzmitry Hubin. All rights reserved.
//

import Foundation

class CurrencyLayer {
    
    func requestCurrencyQuotes(baseCurrency: String = "USD", completionHandler: (success: Bool, quotes: [String:AnyObject]?, error: String!) -> Void) {
        if Reachability.isConnectedToNetwork() {
            
//            let urlString = "http://apilayer.net/api/live?access_key=5edef452618563a7e2c850adb6f428e7&currencies=EUR,GBP,INR&format=1"
//            http://api.fixer.io/latest?base=BRL&symbols=USD,EUR,RUB
            
            
            //TODO change to requested.
            //let urlString = "http://api.fixer.io/latest?base=\(baseCurrency)&symbols=USD,EUR,RUB"
            //base call to fill up all quotes
            let urlString = "http://api.fixer.io/latest?base=\(baseCurrency)"
            let session = NSURLSession.sharedSession()
            let url = NSURL(string: urlString)!
            
            let request = NSURLRequest(URL: url)
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil {
                    completionHandler(success: false, quotes: nil, error: error!.localizedDescription)
                }
                else {
                    do {
                        let result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                            if let dictionary = result["rates"] as? [String:AnyObject]! {
                                completionHandler(success: true, quotes: dictionary, error: nil)
                            }
                            else {
                                completionHandler(success: false, quotes: nil, error: nil)
                            }
                    } catch {
                        completionHandler(success: false, quotes: nil, error: "Unable to process retrieved data.")
                    }
                }
                    
            }
            task.resume()
        }
        else {
            completionHandler(success: false, quotes: nil, error: "Please check you internet connection and try again.")
        }
    }
}