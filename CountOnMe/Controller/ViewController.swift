//
//  ViewController.swift
//  SimpleCalc
//
//  Created by Vincent Saluzzo on 29/03/2019.
//  Copyright © 2019 Vincent Saluzzo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var oCalcModel: CalcModel = CalcModel(decimalPrecision: 3, maxDigitForWholePart: 5, byRecusiveMethod: true)
    
    @IBOutlet weak var oTXTExpression: UITextView!
        
    @IBOutlet var aoBTNOperators: [UIButton]!
    
    @IBOutlet weak var oBTNEqual: UIButton!
    
    @IBOutlet weak var oBTNComma: UIButton!
    
    @IBOutlet var aoBTNDigits: [UIButton]!
    
    // View Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connection to the notification from the CalcModel for expression changed notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.calcExpressionChanged),
                                               name: CalcModel.oNotifNameForExpressionChanged, object: nil)
        
        // Connection to the notification in case of an error message to display
        NotificationCenter.default.addObserver(self, selector: #selector(self.displayErrorMessage),
                                               name: CalcModel.oNotifNameForError, object: nil)
        //display avaibility of the button when the view is launched
        updateButtonAvailibility()
    }
    
    
    /// Display the new expression receive in the notification
    /// - Parameter oNotification: oNotification received with the new expression
    @objc private func calcExpressionChanged(_ oNotification: NSNotification) {
        if let szExpression = oNotification.userInfo?[CalcModel.szExpressionFieldValueInExpressionChangedNotification] as? String {
            self.oTXTExpression.text = szExpression
        }
        //update the accessibility button each time the expression changed
        updateButtonAvailibility()
    }
        
    
    /// Display modal dialog box to display the error message sent by the model
    /// - Parameter oNotification: oNotification containig the notification with error to display
    @objc private func displayErrorMessage(_ oNotification: NSNotification) {
        var szMessage: String = "Une erreur inconnue s'est produite"

        if let oErrorType = oNotification.userInfo?[CalcModel.szErrorTypeFieldValueInErrorNotification] as? CalcModel.Errors {
            szMessage = oErrorType.szErrorMessage
        }
            
        let oAlertDlg = UIAlertController(title: "Erreur", message: szMessage, preferredStyle: .alert)
        oAlertDlg.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(oAlertDlg, animated: true, completion: nil)
    }
        
    /// The user clic on one of the digit button
    /// - Parameter sender: ref to the button cliqued
    @IBAction func tappedDigitButton(_ oSender: UIButton) {
        guard let szNumberText = oSender.title(for: .normal) else {
            return
        }
        
        _ = self.oCalcModel.addDigit(digit: szNumberText)
    }
    
    /// The user clic on one of the operator button
    /// - Parameter sender: ref to the button cliqued
    @IBAction func tappedOnOperatorButton(_ oSender: UIButton) {
        guard let cOperator = getOperator(fromUIButton: oSender) else {
            return
        }
        // we add operator to the model if possible
        _ = self.oCalcModel.addOperator(with: cOperator)
    }

    /// The user clic on equal button
    /// - Parameter sender: ref to the button cliqued
    @IBAction func tappedEqualButton(_ sender: UIButton) {
        _ = self.oCalcModel.calculateExpression()
    }
    
    /// The user clic on clear button
    /// - Parameter sender: ref to the button cliqued
    @IBAction func tappedClearButton(_ sender: UIButton) {
        self.oCalcModel.eraseExpression()
    }
    
    /// The user clic on decimal separator button
    /// - Parameter sender: ref to the button cliqued
    @IBAction func tappedDecimalSeparatorButton(_ sender: Any) {
        _ = self.oCalcModel.addDecimalSeparator()
    }
    
    /// Return the operand corresponding to the UIButton passed
    /// - Parameter oButton: UIButton that we want to know the operand
    /// - Returns: optional of the operand, nil if the operand has not been determined
    private func getOperator(fromUIButton oButton: UIButton) -> CalcModel.OperatorType? {
        // we determine which kind of operator is it
        guard let szOperator = oButton.title(for: .normal) else {
            return nil
        }

        return CalcModel.getOperator(from: szOperator)
    }
    
    /// Each case the expression change, this method is called to control the availability of the buttons
    private func updateButtonAvailibility() {
        makeOperatorButtonsAvailable(to: self.oCalcModel.bCanAddOperator)
        makeEqualButtonAvailable(to: self.oCalcModel.bCanBeCalculated)
        makeDecimalSeparatorButtonAvailable(to: self.oCalcModel.bCanAddDecimalSeparator)
        makeDigitButtonsAvailable(to: self.oCalcModel.bCanAddDigit)
    }
    
    /// Control the availability for the operator buttons and give then a unvailable apparence in case of non availability
    /// - Parameter bAccess: true if need to appear available, false else not available
    private func makeOperatorButtonsAvailable(to bAccess: Bool) {
        for oButton in self.aoBTNOperators {
            oButton.isEnabled = bAccess
            oButton.alpha = bAccess ?  1 : 0.3
        }
    }
    
    /// Control the availability for the equal button and give it a unvailable apparence in case of non availability
    /// - Parameter bAccess: true if need to appear available, false else not available
    private func makeEqualButtonAvailable(to bAccess: Bool) {
        self.oBTNEqual.isEnabled = bAccess
        self.oBTNEqual.alpha = bAccess ? 1 : 0.3
    }
    
    /// Control the availability for the decimal separator button and give it a unvailable apparence in case of non availability
    /// - Parameter bAccess: true if need to appear available, false else not available
    private func makeDecimalSeparatorButtonAvailable(to bAccess: Bool) {
        self.oBTNComma.isEnabled = bAccess
        self.oBTNComma.alpha = bAccess ? 1 : 0.3
    }
    
    /// Control the availability for the digit buttons and give then a unvailable apparence in case of non availability
    /// - Parameter bAccess: true if need to appear available, false else not available
    private func makeDigitButtonsAvailable(to bAccess: Bool) {
        for oButton in self.aoBTNDigits {
            oButton.isEnabled = bAccess
            oButton.alpha = bAccess ? 1 : 0.3
        }
    }
                           

}

