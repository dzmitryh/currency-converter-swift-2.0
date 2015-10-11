//
//  CurrencyLayer.swift
//  Currency Converter
//
//  Created by Mayank Kumar on 7/28/15.
//  Copyright (c) 2015 Mayank Kumar. All rights reserved.
//

import Foundation

class CurrencyLayer {
    
    func requestCurrencyQuotes(completionHandler: (success: Bool, quotes: [String:AnyObject]?, error: String!) -> Void) {
        if Reachability.isConnectedToNetwork() {
            let urlString = "http://apilayer.net/api/live?access_key=bcd58c132d287dc4b443f5e1f3eb59e1&currencies=EUR,GBP,INR&format=1"
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
                            if let dictionary = result["quotes"] as? [String:AnyObject]! {
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