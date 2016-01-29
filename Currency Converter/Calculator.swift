//
//  Calculator.swift
//  Currency Converter
//
//  Created by Dzmitry Hubin on 1/28/16.
//  Copyright (c) 2015 Dzmitry Hubin. All rights reserved.
//

import Foundation

class Calculator {
    
    enum Operator {
        case Plus
        case Minus
        case Multiply
        case Divide
    }
    
    var firstNumber: Float?
    var secondNumber:Float?
    var tempResult: Float?
    var operation: Operator?
    
    func doCalculation(operation: Operator, valueOne: Float, valueTwo: Float) -> Float {
        
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
        
        return res
    }

}
