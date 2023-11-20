//
//  CalcModel.swift
//  CountOnMe
//
//  Created by Stéphane LEGUILLIER on 08/11/2023.
//  Copyright © 2023 Vincent Saluzzo. All rights reserved.
//

import Foundation

enum OperatorType {case add, subs, mult, div}

class CalcModel {

    // possible errors
    enum Errors {case operatorMissing, expressionCanNotBeCalculated, operatorUnknown, operatorNotAfterNumber, Overflow,
                      NotADigit, DivBy0, AddDigitNotPossible, AddDecimalSeparatorNotPossible, OneOperandIsNotNumber
        var szErrorMessage: String {
            switch self {
                case .operatorMissing: return "Opérateur manquant"
                case .expressionCanNotBeCalculated: return "Expression se termine par un opérateur ou n'a pas d'opérateur"
                case .operatorUnknown: return "Opérateur inconnu"
                case .operatorNotAfterNumber: return "Un opérateur doit être utilisé après un nombre"
                case .Overflow: return "Le calcul a dépassé la capacité autorisée"
                case .NotADigit: return "Touche tapée n'est pas un chiffre"
                case .DivBy0: return "Division par 0 impossible"
                case .AddDigitNotPossible: return "Trop de chiffres pour la partie entière ou décimale"
                case .AddDecimalSeparatorNotPossible: return "L'expression est vide, ou contient déjà un décimal ou bien un opérateur ou résultat"
                case .OneOperandIsNotNumber: return "Un des opérande n'est pas un nombre"
            }
        }
    }
    
    // kind of items possible
    enum ItemType {case emptyType, integerType, decimalType, operatorType, unknownType, resultType}

    // operators availables and their display in the expression
    static let aszOperatorsAvailable: [OperatorType : String] = [.add : "+", .subs : "-", .div : "÷", .mult : "x"]
    // decimal separator used in the expression
    static let szDecimalSeparator: Character = "."
    /// number of digit accepted after the decimal separator
    static let iPrecisionForDecimal: Int = 2
    /// number max digit accepted for the whole part
    static let iMaxNumberOfDigit: Int = 3
    
    // to manage the notification when expression chang
    static let oNotifNameForExpressionChanged = NSNotification.Name(rawValue: "CalcModelExpressionChanged")
    static let szExpressionFieldValue_For_ExpressionChangedNotification: String = "newExpression"
    
    // to manage notfication when model raise an error
    static let oNotifNameForError = NSNotification.Name(rawValue: "CalcModelErrorAlert")
    static let szErrorTypeFieldValue_For_ErrorNotification: String = "errorType"

    
    // expression that will be displayed by view
    // each time it changes, it times it notifies
    private var szExpression: String = "" {
        didSet {
            // contruct data structure to transmit value of the expression
            let aszUserData: [String : String] = [CalcModel.szExpressionFieldValue_For_ExpressionChangedNotification : szExpression]
            
            // post notification
            NotificationCenter.default.post(name: CalcModel.oNotifNameForExpressionChanged, object: nil, userInfo: aszUserData)
        }
    }
    
    /// create a notification to indicate that there is an error, the controller can choose to display it or not
    /// - Parameter oErrorType: error type to notify
    private func notifyError(with oErrorType: CalcModel.Errors) {
        // contruct data structure to transmitt
        let aszUserData: [String : CalcModel.Errors] = [CalcModel.szErrorTypeFieldValue_For_ErrorNotification : oErrorType]
        
        // post notification
        NotificationCenter.default.post(name: CalcModel.oNotifNameForError, object: nil, userInfo: aszUserData)
    }
    
    /// retruns an String array with all items composing the expression separate by space caracter
    private var aszElements: [String] {
        return self.szExpression.split(separator: " ").map { "\($0)" }
    }
    
    /// returns true if the expression is empty
    var bExpressionIsEmpty: Bool {
        return self.szExpression.isEmpty
    }
    
    /// To know if an opérator can be add at the end of the expression
    var bCanAddOperator: Bool {
        switch(kindOfTypeForLastItem()) {
            case .decimalType, .integerType, .resultType: return true
            case .operatorType, .unknownType, .emptyType: return false
        }
    }
    
    /// True if the expression is ready to be calculated
    var bCanBeCalculated: Bool {
        if (self.aszElements.count == 1) || bExpressionHaveResult {
            return false
        }
        
        return self.aszElements.count % 2 == 1
    }

    /// return true if the expression have already has been calculated
    var bExpressionHaveResult: Bool {
        return kindOfTypeForLastItem() == .resultType
    }
    
    /// Return true if the last item of the expression can receive a decimal separator (is an integer)
    var bCanAddDecimalSeparator: Bool {
        switch(kindOfTypeForLastItem()) {
            case .integerType: return true
            case .operatorType, .unknownType, .emptyType, .decimalType, .resultType: return false
        }
    }
    
    /// returns true if a digit can be add to the expression
    var bCanAddDigit: Bool {
        var bReturn: Bool = false
        
        //no last element, expression is empty
        guard let szLastElement = self.aszElements.last else {
            return true
        }
        
        switch(CalcModel.kindOfItem(forItem: szLastElement))
        {
            case .emptyType, .operatorType, .resultType:
                bReturn = true
                break
            
            case .integerType:
                let iNumberOfDigitEntirePart = CalcModel.getNumberDigitEntirePart(forItem: szLastElement)
                bReturn = iNumberOfDigitEntirePart < CalcModel.iMaxNumberOfDigit
                break
            
            case .decimalType:
                let iPrecision = CalcModel.getPrecision(forItem: szLastElement)
                bReturn = iPrecision < CalcModel.iPrecisionForDecimal
                break
            
            case .unknownType:
                bReturn = false
                break
        }
        
        return bReturn
    }
    
    /// Add one digit (0-9) to the expression
    /// - Parameter szDigit: digit to add
    /// - Returns: return true if the digit could have been added, else return false
    func addDigit(digit szDigit: String) -> Bool {
        if szDigit.count != 1 || !"0123456789".contains(szDigit) {
            notifyError(with: .NotADigit)
            return false
        }
        
        // if the user have a calculuted expression displayed
        // then the expression is erased
        if self.bExpressionHaveResult {
            eraseExpression()
        }
        
        if self.bCanAddDigit {
            self.szExpression.append(szDigit)
            return true
        } else {
            notifyError(with: .AddDigitNotPossible)
            return false
        }
    }
    
    /// Add a decimal separator only if the last item of the expression is a integer
    /// - Returns: return true if the decimal separator have been add
    func addDecimalSeparator() -> Bool {
        if self.bCanAddDecimalSeparator {
            self.szExpression.append(CalcModel.szDecimalSeparator)
            return true
        } else {
            notifyError(with: .AddDecimalSeparatorNotPossible)
            return false
        }
    }
    
    /// Add an operator to the expression, if the expression have a result, it takes the result for the first operand
    /// - Parameter cOperator: kind of operator to add
    /// - Returns: true if the operator have been add
    func addOperator(with cOperator: OperatorType) -> Bool {
        var bReturn: Bool = true
        
        if self.bCanAddOperator {
            // If the precedent expression has been calculated
            // then the result is conserved for the first operand
            if self.bExpressionHaveResult {
                if let szLastElement = self.aszElements.last {
                    self.szExpression = szLastElement
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
            notifyError(with: .operatorNotAfterNumber)
        }
        
        return bReturn
    }
    
    
    /// Return the value of the current expression
    /// - Returns: the string representing the current expression
    func getExpression() -> String {
        return self.szExpression
    }
    
    
    /// When the expression can be calculated, then calculate the value and add ' = ' + result to the expression
    /// - Returns: true if the expression could have been evaluated
    func calculateExpression() -> Bool {
        var bReturn: Bool = false
        
        if self.bCanBeCalculated {
            bReturn = calculateWithDecimal()
        } else {
            notifyError(with: .expressionCanNotBeCalculated )
        }
        
        return bReturn
    }
    
    /// Calculate the expression by converting items in Decimal objets
    /// - Returns: true if the calcul is OK
    private func calculateWithDecimal() -> Bool {
        // Create local copy of operations
        var aszOperationsToReduce = self.aszElements
        
        // Iterate over operations while an operand still here
        while aszOperationsToReduce.count > 2 {
            guard let dLeft: Decimal = Decimal(string: aszOperationsToReduce[0]), 
                    let dRight: Decimal = Decimal(string: aszOperationsToReduce[2]) else {
                notifyError(with: .OneOperandIsNotNumber)
                return false
            }
            let szOperator = aszOperationsToReduce[1]
            guard let oOperator: OperatorType = CalcModel.getOperator(from: szOperator) else {
                notifyError(with: .operatorMissing)
                return false
            }
            
            print("Pour \(aszOperationsToReduce[0]) : \(dLeft.significand) § \(dLeft.magnitude) § \(dLeft.exponent)")
            print("Pour \(aszOperationsToReduce[2]) : \(dRight.significand) § \(dRight.magnitude) § \(dRight.exponent)")

            var dResult: Decimal
            switch oOperator {
                case .add: dResult = dLeft + dRight
                case .subs: dResult = dLeft - dRight
                case .mult: dResult = dLeft * dRight
                case .div: dResult = dLeft / dRight
            }
            
            if dResult.isNaN {
                eraseExpression()
                notifyError(with: .DivBy0)
                return false
            }
            
            if dResult >= CalcModel.maxValue() {
                eraseExpression()
                notifyError(with: .Overflow)
                return false
            }
            aszOperationsToReduce = Array(aszOperationsToReduce.dropFirst(3))

        
            var dRoundedValue: Decimal = Decimal()
            NSDecimalRound(&dRoundedValue, &dResult, CalcModel.iPrecisionForDecimal, NSDecimalNumber.RoundingMode.bankers)
            aszOperationsToReduce.insert("\(dRoundedValue)", at: 0)
        }
        
        self.szExpression.append(" = \(aszOperationsToReduce.first!)")
        
        return true
    }
    
    /// to put the expression to "", used for C touch
    func eraseExpression() {
        self.szExpression = ""
    }
    
    /// Return the number of digit after the decimal separator
    /// - Parameter szItem: Item to analyse
    /// - Returns: number of digit after decimal separator
    static func getPrecision(forItem szItem: String) -> Int {
        let iNumberOfDigit = CalcModel.getNumberDigitEntirePart(forItem: szItem)
        
        // it is not a Decimal
        if iNumberOfDigit == -1 {
            return -1
        }
        
        if iNumberOfDigit == szItem.count {
            return 0
        }

        return szItem.count - iNumberOfDigit - 1
    }
    
    /// return the number of the  digit that define the whole part of decimal number
    /// - Parameter szItem: string representing the decimal to evaluate
    /// - Returns: number of digit of the whole part of the decimal
    static func getNumberDigitEntirePart(forItem szItem: String) -> Int {
        let oTypeItem = CalcModel.kindOfItem(forItem: szItem)
        switch(oTypeItem) {
        case .emptyType: return 0
        case .operatorType, .resultType, .unknownType: return -1
        case .integerType: return szItem.count
        case .decimalType:
            guard let dValue: Decimal = Decimal(string: szItem) else {
                return -1
            }
            return szItem.count + dValue.exponent - 1
        }
    }
        
    /// return the type of the item passed
    /// - Parameter szItem: item to analyse
    /// - Returns: type of the item
    private static func kindOfItem(forItem szItem: String) -> ItemType {
        var eReturn: ItemType = .unknownType
        
        if szItem.isEmpty {
            return .emptyType
        }
        
        // An operator is only one character and is in the map aszOperatorsAvailable values
        if szItem.count == 1 && CalcModel.aszOperatorsAvailable.contains(where: { (key: OperatorType, value: String) in value == szItem }) {
            return .operatorType
        }
        
        let acDigitsCharacters = CharacterSet(charactersIn: "0123456789.")
        if CharacterSet(charactersIn: szItem).isSubset(of: acDigitsCharacters) {
            if szItem.contains(CalcModel.szDecimalSeparator) {
                eReturn = .decimalType
            } else {
                eReturn = .integerType
            }
        }
        
        return eReturn
    }
    
    /// Evaluate the type of the last item
    /// - Returns: type of the last item of the expression
    private func kindOfTypeForLastItem() -> ItemType {
        guard let szLastElement = self.aszElements.last else {
            return ItemType.emptyType
        }
        
        // test if there is an equal in the expression
        if let _ = self.szExpression.firstIndex(of: "=") {
            return ItemType.resultType
        }
        
        return CalcModel.kindOfItem(forItem: szLastElement)
    }
    
    
    /// return the type of the operator given by the szItem
    /// - Parameter szItem: Item representing the operator in string format
    /// - Returns: type of the operator corresponding to the string representing the item
    static func getOperator(from szItem: String) -> OperatorType? {
        return CalcModel.aszOperatorsAvailable.first(where: { $1 == szItem })?.key
    }
    
    /// return the max value possible with the actual config of the calculate
    /// - Returns: decimal number that is consider of out of overflow of calculating
    static func maxValue() -> Decimal {
        let szMaxNumber: String = "1" + String(repeating: "0", count: CalcModel.iMaxNumberOfDigit)
        
        if let dReturn = Decimal(string: szMaxNumber) {
            return dReturn
        } else {
            return Decimal(-1)
        }
    }
    
}
