//
//  CalcModel.swift
//  CountOnMe
//
//  Created by Stéphane LEGUILLIER on 08/11/2023.
//  Copyright © 2023 Stéphane LEGUILLIER. All rights reserved.
//

import Foundation



class CalcModel {

    enum OperatorType : String
    {
        case add = "+"
        case subs = "-"
        case mult = "x"
        case div = "÷"
        
        var mathematicOperation: ((Decimal, Decimal) -> Decimal) {
            switch self {
                case .add: return (+)
                case .subs: return (-)
                case .div: return (/)
                case .mult: return (*)
            }
        }
    }
    
    /**
     Errors thrown by CalcModel

     *Values*
     
     `operatorMissing` Operator is missing in the expression for calculate it.
     
     `expressionCanNotBeCalculated` Something is missing in the expression to be calculated.
     
     `operatorNotAfterNumber` to can add an operator to expression, it has to be done after a number or just after a result
     
     `overflow` when calaculte the expression, the result is over the max digit permetted
     
     `notADigit` digit passed in the argument is not a digit 0...9
     
     `divBy0` When calculating the expression, a division by 0 is done
     
     `addDigitImpossible` When trying to add digit to the expression, the last number obtained is over the maximum number of digits permetted
     
     `addDecimalSeparatorNotPossible` adding a decimal separator not after an integer number
     
     `oneOfOperandIsNotNumber` when calculating the expression, one of the operand of the operator is not a number
     
     */
    enum Errors {case operatorMissing, expressionCanNotBeCalculated, operatorNotAfterNumber, overflow,
                      notADigit, divBy0, addDigitImpossible, addDecimalSeparatorNotPossible, oneOfOperandIsNotNumber
        var szErrorMessage: String {
            switch self {
                case .operatorMissing: return "Opérateur manquant"
                case .expressionCanNotBeCalculated: return "Expression se termine par un opérateur ou elle n'a pas d'opérateur"
                case .operatorNotAfterNumber: return "Un opérateur doit être utilisé après un nombre"
                case .overflow: return "Le calcul a dépassé la capacité autorisée"
                case .notADigit: return "Touche tapée n'est pas un chiffre"
                case .divBy0: return "Division par 0 impossible"
                case .addDigitImpossible: return "Trop de chiffres pour la partie entière ou décimale"
                case .addDecimalSeparatorNotPossible: return "L'expression est vide, ou contient déjà un décimal ou bien un opérateur ou résultat"
                case .oneOfOperandIsNotNumber: return "Un des opérandes n'est pas un nombre"
            }
        }
    }
    
    // kind of items possible
    enum ItemType {case emptyType, integerType, decimalType, operatorType, unknownType, resultType}

    // decimal separator used in the expression
    static let szDecimalSeparator: Character = "."
    
    // to manage the notification when expression chang
    static let oNotifNameForExpressionChanged = NSNotification.Name(rawValue: "CalcModelExpressionChanged")
    static let szExpressionFieldValueInExpressionChangedNotification: String = "newExpression"
    
    // to manage notfication when model raise an error
    static let oNotifNameForError = NSNotification.Name(rawValue: "CalcModelErrorAlert")
    static let szErrorTypeFieldValueInErrorNotification: String = "errorType"

    // expression that will be displayed by view
    // each time it changes, it times it notifies
    private var szExpression: String = "" {
        didSet {
            // contruct data structure to transmit value of the expression
            let aszUserData: [String : String] = [CalcModel.szExpressionFieldValueInExpressionChangedNotification : szExpression]
            
            // post notification
            NotificationCenter.default.post(name: CalcModel.oNotifNameForExpressionChanged, object: nil, userInfo: aszUserData)
        }
    }
    
    /// number of digit accepted after the decimal separator
    private var iPrecisionForDecimal: Int = 10
    /// number max digit accepted for the whole part
    private var iMaxNumberOfDigit: Int = 15
    
    /// to determine witch type of calculation to be applied (loop or recursive)
    private var bCalculateByRecursiveMode = false
    
    /// class constructor
    /// - Parameters:
    ///   - iPrecisionForDecimal: number of digits after the decimal separator autorised
    ///   - iMaxNumberOfDigit: number of digits before the decimal separator
    init(decimalPrecision iPrecisionForDecimal: Int, maxDigitForWholePart iMaxNumberOfDigit: Int) {
        self.iPrecisionForDecimal = iPrecisionForDecimal
        self.iMaxNumberOfDigit = iMaxNumberOfDigit
    }
    
    /// class constructor
    /// - Parameters:
    ///   - iPrecisionForDecimal: number of digits after the decimal separator autorised
    ///   - iMaxNumberOfDigit: number of digits before the decimal separator
    ///   - bReursive: true if the calcul has to be done in recursive mode
    convenience init(decimalPrecision iPrecisionForDecimal: Int, maxDigitForWholePart iMaxNumberOfDigit: Int, byRecusiveMethod bReursive: Bool) {
        self.init(decimalPrecision: iPrecisionForDecimal, maxDigitForWholePart: iMaxNumberOfDigit)
        self.bCalculateByRecursiveMode = bReursive
    }
    
    /// create a notification to indicate that there is an error, the controller can choose to display it or not
    /// - Parameter oErrorType: error type to notify
    private func notifyError(with oErrorType: CalcModel.Errors) {
        // contruct data structure to transmitt
        let aszUserData: [String : CalcModel.Errors] = [CalcModel.szErrorTypeFieldValueInErrorNotification : oErrorType]
        
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
        if (self.aszElements.count == 1) || self.bExpressionHaveResult {
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
        return self.kindOfTypeForLastItem() == .integerType ? true : false
    }
    
    /// returns true if a digit can be add to the expression
    var bCanAddDigit: Bool {
        var bReturn: Bool = false
        
        //no last element, expression is empty
        guard let szLastElement = self.aszElements.last else {
            return true
        }
        
        switch(kindOfTypeForLastItem())
        {
            case .emptyType, .operatorType, .resultType:
                bReturn = true
                break
            
            case .integerType:
                let iNumberOfDigitEntirePart = CalcModel.getNumberDigitEntirePart(forItem: szLastElement)
                bReturn = iNumberOfDigitEntirePart < self.iMaxNumberOfDigit
                break
            
            case .decimalType:
                let iPrecision = CalcModel.getPrecision(forItem: szLastElement)
                bReturn = iPrecision < self.iPrecisionForDecimal
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
        let bReturn: Bool = bCanAddDigit
        
        if szDigit.count != 1 || !"0123456789".contains(szDigit) {
            notifyError(with: .notADigit)
            return false
        }
        
        // if the user have a calculuted expression displayed
        // then the expression is erased
        if self.bExpressionHaveResult {
            eraseExpression()
        }
        //we add the digit to the expression if possible, else notify error
        self.bCanAddDigit ? self.szExpression.append(szDigit) : notifyError(with: .addDigitImpossible)
        
        return bReturn
    }
    
    /// Add a decimal separator only if the last item of the expression is a integer
    /// - Returns: return true if the decimal separator have been add
    func addDecimalSeparator() -> Bool {
        let bReturn: Bool = self.bCanAddDecimalSeparator
        
        self.bCanAddDecimalSeparator ? self.szExpression.append(CalcModel.szDecimalSeparator)
                                        : notifyError(with: .addDecimalSeparatorNotPossible)
        
        return bReturn
    }
    
    /// Add an operator to the expression, if the expression have a result, it takes the result for the first operand
    /// - Parameter cOperator: kind of operator to add
    /// - Returns: true if the operator have been add
    func addOperator(with cOperator: OperatorType) -> Bool {
        let bReturn: Bool = self.bCanAddOperator
        
        if self.bCanAddOperator {
            // If the precedent expression has been calculated
            // then the result is conserved for the first operand
            if self.bExpressionHaveResult {
                if let szLastElement = self.aszElements.last {
                    self.szExpression = szLastElement
                }
            }
            //we add the new operator to the expression
            self.szExpression.append(" " + cOperator.rawValue + " ")

        } else {
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
            if self.bCalculateByRecursiveMode {
                var aszItemsToReduce: [String] = self.aszElements
                if let dResult = calculateRecursively(with: &aszItemsToReduce) {
                    self.szExpression.append(" = \(dResult)")
                    bReturn = true
                } else {
                    print("Invalid expression")
                }
            } else {
                bReturn = calculateWithDecimal()
            }
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
            var iNextPosOperatorToCalcule = 1
            if let iTmp = getPositionOfNextOperatorToCalculate(with: aszOperationsToReduce) {
                iNextPosOperatorToCalcule = iTmp
            }
            
            guard let dLeft: Decimal = Decimal(string: aszOperationsToReduce[iNextPosOperatorToCalcule - 1]),
                    let dRight: Decimal = Decimal(string: aszOperationsToReduce[iNextPosOperatorToCalcule + 1]) else {
                notifyError(with: .oneOfOperandIsNotNumber)
                return false
            }
            let szOperator = aszOperationsToReduce[iNextPosOperatorToCalcule]
            guard let oOperator: OperatorType = CalcModel.getOperator(from: szOperator) else {
                notifyError(with: .operatorMissing)
                return false
            }

            var dResult: Decimal
            
            //we use one of calculated attribute of the enum to do the correct operation
            dResult = oOperator.mathematicOperation(dLeft, dRight)

            if dResult.isNaN {
                eraseExpression()
                notifyError(with: .divBy0)
                return false
            }
            
            if dResult >= self.maxValue() {
                eraseExpression()
                notifyError(with: .overflow)
                return false
            }
            aszOperationsToReduce.remove(at: iNextPosOperatorToCalcule + 1)
            aszOperationsToReduce.remove(at: iNextPosOperatorToCalcule)
            aszOperationsToReduce.remove(at: iNextPosOperatorToCalcule - 1)

            var dRoundedValue: Decimal = Decimal()
            NSDecimalRound(&dRoundedValue, &dResult, self.iPrecisionForDecimal, NSDecimalNumber.RoundingMode.bankers)
            aszOperationsToReduce.insert("\(dRoundedValue)", at: iNextPosOperatorToCalcule - 1)
        }
        
        self.szExpression.append(" = \(aszOperationsToReduce.first!)")
        
        return true
    }
    
    
    private func getPositionOfNextOperatorToCalculate(with aszElements: [String]) -> Int? {

        return aszElements.firstIndex(where: {(szElement) -> Bool in
            return szElement == CalcModel.OperatorType.mult.rawValue ||
            szElement == CalcModel.OperatorType.div.rawValue
        })
    }
    
    /// Transform the given array to a new array by replacing the 3 firsts items by the value passed
    /// - Parameters:
    ///   - dValue: reult of the calculation of the 2 first operands and its operator in the aszItems
    ///   - aszItems: array of initial items composing the expression to calculate
    /// - Returns: new string array after replacing the first calcul to be done in the expression by the result passed in the argument.
    ///            Could be nil if the value is no good or expression no good
    private func arrangeExpressionWithNewResult(for dValue: Decimal, withExpression aszItems: [String]) -> [String]? {
        var aszReturn: [String]?
        
         if aszItems.count > 2 {
             if let dValueFormatted = getDecimalWellFormatted(for: dValue) {
                 aszReturn = aszItems
                 aszReturn!.removeFirst(3)
                 aszReturn!.insert("\(dValueFormatted)", at: 0)
             }
        }
        
        return aszReturn
    }
    
    private func getDecimalWellFormatted(for dValue: Decimal?) -> Decimal? {
        var dReturn: Decimal?
        
        guard var dValueToUse = dValue else {
            return dReturn
        }
        
        if dValueToUse.isNaN {
            notifyError(with: .divBy0)
            return dReturn
        }
        
        if dValueToUse >= self.maxValue() {
            notifyError(with: .overflow)
            return dReturn
        }
        
        dReturn = Decimal()
        NSDecimalRound(&dReturn!, &dValueToUse, self.iPrecisionForDecimal, NSDecimalNumber.RoundingMode.bankers)
        
        return dReturn

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
            eReturn = .emptyType
        }
        
        if let _ = OperatorType.init(rawValue: szItem) {
            eReturn = .operatorType
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
        // the expression is empty, no last item
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
        return OperatorType.init(rawValue: szItem)
    }
    
    /// return the max value possible with the actual config of the calculate
    /// - Returns: decimal number that is consider of out of overflow of calculating
    private func maxValue() -> Decimal {
        let szMaxNumber: String = "1" + String(repeating: "0", count: self.iMaxNumberOfDigit)
        
        if let dReturn = Decimal(string: szMaxNumber) {
            return dReturn
        } else {
            return Decimal(-1)
        }
    }
    
    /// - Parameter aszItems: array containing all the items of the expression, this array is changing during calculation
    ///
    /// - Returns: the result of the calculation of the expression passed as an array
    private func calculateRecursively(with aszItems: inout [String]) -> Decimal? {
        var dReturn: Decimal?
        
        if let dArg1 = getNextNumber(with: &aszItems) {
            if aszItems.isEmpty {
                dReturn = dArg1
            } else {
                if let oOperator1 = getNextOperator(with: &aszItems) {
                    if let dArg2 = getNextNumber(with: &aszItems) {
                        if oOperator1 == .mult || oOperator1 == .div || aszItems.isEmpty {
                            // the first operator is prior, so we do the calculation with this operator
                            if let dResult = getDecimalWellFormatted(for: oOperator1.mathematicOperation(dArg1, dArg2)) {
                                // we insert the result in the array at the begining and we call recursively the same method
                                aszItems.insert("\(dResult)", at: 0)
                                dReturn = getDecimalWellFormatted(for: calculateRecursively(with: &aszItems))
                            }
                        } else {
                            // the first operator is not prior
                            // we have to check the second operator to see if it is prior operator
                            if let oOperator2 = getNextOperator(with: &aszItems) {
                                if oOperator2 == .div || oOperator2 == .mult {
                                    // the second operator is prior to the first one, so we execute firt the operation with operator 2
                                    if let dArg3 = getNextNumber(with: &aszItems)
                                    {
                                        if let dResult = getDecimalWellFormatted(for: oOperator2.mathematicOperation(dArg2, dArg3)) {
                                            // we add the result with the second operator to the array
                                            aszItems.insert("\(dResult)", at: 0)
                                            // we add the operator 1 and the arg 1 to the array to make the first operation calling recursively
                                            aszItems.insert(oOperator1.rawValue, at: 0)
                                            aszItems.insert("\(dArg1)", at: 0)
                                            dReturn = getDecimalWellFormatted(for: calculateRecursively(with: &aszItems))
                                        }
                                    }
                                } else {
                                    // operator 2 is not prior so we do the operation with operator 1 by putting back the operator 2 in the array
                                    aszItems.insert(oOperator2.rawValue, at: 0)
                                    // we do the operation 1 and put the result in the array to can call recursively this method
                                    let dResult = oOperator1.mathematicOperation(dArg1, dArg2)
                                    aszItems.insert("\(dResult)", at: 0)
                                    dReturn = getDecimalWellFormatted(for: calculateRecursively(with: &aszItems))
                                }
                            }
                        }
                    }
                }
            }
        }
        return dReturn
    }
    
    /// Give the decimal representing the first Item in the array and remove it from the array if it is a Decimal
    /// - Parameter aszItems: array representing the expression to calculate
    /// - Returns: decimal representing the first element of the expression, nil if the array is empty or if the first element is not a decimal
    private func getNextNumber(with aszItems: inout [String]) -> Decimal? {
        
        if aszItems.isEmpty {
            return nil
        }
        
        guard let dreturn: Decimal = Decimal(string: aszItems[0]) else {
            notifyError(with: .oneOfOperandIsNotNumber)
            return nil
        }
        aszItems.removeFirst()
        
        return dreturn
    }
    
    /// return the operator represnting the first element of the expression passed as an array
    /// - Parameter aszItems: expression reprented as an array
    /// - Returns: operator find in the first position, nil if the array was empty or if it is not an operator
    private func getNextOperator(with aszItems: inout [String]) -> OperatorType? {
        if aszItems.isEmpty {
            return nil
        }
        
        let szOperator = aszItems[0]
        guard let oOperator: OperatorType = CalcModel.getOperator(from: szOperator) else {
            notifyError(with: .operatorMissing)
            return nil
        }
        aszItems.removeFirst()
        return oOperator
    }
    
}
