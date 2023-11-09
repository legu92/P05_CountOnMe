//
//  CalcModel.swift
//  CountOnMe
//
//  Created by Stéphane LEGUILLIER on 08/11/2023.
//  Copyright © 2023 Vincent Saluzzo. All rights reserved.
//

import Foundation

enum Operand {case add, subs, mult, div}

class CalcModel {
    static let aszOperatorsAvailable: [Operand : String] = [.add : "+", .subs : "-", .div : "÷", .mult : "x"]
    
    private var szExpression: String = ""
    
    /// Give back a string with all operators available as an visual operand
    static var szAllOperators: String {
        let (_,szOperators) = CalcModel.aszOperatorsAvailable.reduce(("","")) {return ("", $0.1 + $1.1)}
        return szOperators
    }
    
    private var aszElements: [String] {
        return self.szExpression.split(separator: " ").map { "\($0)" }
    }
    
    /// To know if an opérator can be add at the ennd
    var bCanAddOperator: Bool {
        guard let szLastElement = self.aszElements.last else {
            return false
        }
        return !CalcModel.szAllOperators.contains(szLastElement)
    }
    
    /// To know if the expression can be calculated
    var bExpressionCanBeCalculated: Bool {
        if self.aszElements.count == 1 {
            return false
        }
        
        return self.aszElements.count % 2 == 1
    }
    
    var bExpressionHaveResult: Bool {
        return self.szExpression.firstIndex(of: "=") != nil
    }
    
    /// Add one digit (0-9) to the expression
    /// - Parameter szDigit: digit to add
    /// - Returns: return true if the digit could have been added, else return false
    func addDigit(digit szDigit: String) -> Bool {
        if szDigit.count != 1 || !"0123456789".contains(szDigit) {
            return false
        }
        
        // if the user have a calculuted expression displayed
        // then the expression is erased
        if self.bExpressionHaveResult {
            eraseExpression()
        }
        
        self.szExpression.append(szDigit)
        
        return true
    }
    
    func addOperator(with cOperator: Operand) -> Bool {
        var bReturn: Bool = true
        
        if self.bCanAddOperator {
            // If the precedent expression has been calculated
            // then the result is conserved for the first operand
            if self.bExpressionHaveResult {
                if let szLastElement = self.aszElements.last {
                    self.szExpression = szLastElement
                } else {
                    eraseExpression()
                }
            }
            switch cOperator {
                case .add:
                    self.szExpression.append(" + ")
                    break
                    
                case .subs:
                    self.szExpression.append(" - ")
                    break
                    
                case .mult:
                    self.szExpression.append(" x ")
                    break
                    
                case .div:
                    self.szExpression.append(" ÷ ")
                    break
            }
        } else {
            bReturn = false
        }
        
        return bReturn
    }
    
    func getExpression() -> String {
        return self.szExpression
    }
    
    func calculateExpression() -> Bool {
        var bReturn: Bool = false
        
        if self.bExpressionCanBeCalculated {
            // Create local copy of operations
            var aszOperationsToReduce = self.aszElements
            
            // Iterate over operations while an operand still here
            while aszOperationsToReduce.count > 2 {
                let iLeft = Int(aszOperationsToReduce[0])!
                let szOperand = aszOperationsToReduce[1]
                let iRight = Int(aszOperationsToReduce[2])!
                
                let iResult: Int
                switch szOperand {
                    case "+": iResult = iLeft + iRight
                    case "-": iResult = iLeft - iRight
                    case "x": iResult = iLeft * iRight
                    case "÷": iResult = iLeft / iRight
                    default: fatalError("Unknown operator !")
                }
                
                aszOperationsToReduce = Array(aszOperationsToReduce.dropFirst(3))
                aszOperationsToReduce.insert("\(iResult)", at: 0)
            }
            
            self.szExpression.append(" = \(aszOperationsToReduce.first!)")
            
            bReturn = true
        }
        
        return bReturn
    }
    
    func eraseExpression() {
        self.szExpression = ""
    }

}
