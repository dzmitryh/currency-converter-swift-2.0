//
//  Currency.swift
//  Currency Converter
//
//  Created by Dzmitry Hubin on 1/29/16.
//  Copyright © 2016 Dzmitry Hubin. All rights reserved.
//

import Foundation

class Currency {
    var name: String
    var rate: AnyObject
    
    init(name: String, rate: AnyObject) {
        self.name = name
        self.rate = rate
    }
}
