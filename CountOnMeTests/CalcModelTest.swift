//
//  CalcModelTest.swift
//  CountOnMeTests
//
//  Created by Stéphane LEGUILLIER on 08/11/2023.
//  Copyright © 2023 Vincent Saluzzo. All rights reserved.
//

import XCTest
@testable import CountOnMe

final class CalcModelTest: XCTestCase {
    
    var oCalcModel: CalcModel! = nil
    
    override func setUp() {
        super.setUp()
        oCalcModel = CalcModel()
    }
    
    func testGivenCalcModelJustCreated_WhenAskingForExpression_ThenExpressionIsAEmptyString() {
        // MARK: - GIVEN
        
        
        // MARK: - WHEN
        let szExpresion = oCalcModel.getExpression()
        
        // MARK: - THEN
        XCTAssertNotNil(szExpresion)
        XCTAssertEqual("",szExpresion)
        
    }
    
    func testGivenExpressionIsEmpty_WhenAddingADigit_ThenExpressionContainJustTheDigit() {
        // MARK: - GIVEN
        
        // MARK: - WHEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "1")
    }
    
    func testGivenExpressionHave1value_WhenAddingADigit2_ThenExpressionContains12() {
        // MARK: - GIVEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        
        // MARK: - WHEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "2"))
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "12")
    }
    
    func testGivenExpressionHave1value_WhenAddingANonDigit_ThenExpressionContains1() {
        // MARK: - GIVEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        
        // MARK: - WHEN
        XCTAssertFalse(oCalcModel.addDigit(digit: "h"))
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "1")
    }
    
    func testGivenExpressionHave1value_WhenAdding2Digits_ThenExpressionContains1() {
        // MARK: - GIVEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        
        // MARK: - WHEN
        XCTAssertFalse(oCalcModel.addDigit(digit: "12"))
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "1")
    }
    
    func testGivenExpressionHave1value_WhenAdding0Digit_ThenExpressionContains1() {
        // MARK: - GIVEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        
        // MARK: - WHEN
        XCTAssertFalse(oCalcModel.addDigit(digit: ""))
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "1")
    }
    
    func testGivenExpressionHave1Plusvalue_WhenAdding2AsDigit_ThenExpressionContains1Plus2() {
        // MARK: - GIVEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(oCalcModel.addOperator(with: .add))
        
        // MARK: - WHEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "2"))
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "1 + 2")
    }
    
    func testGivenExpressionHaveNovalue_WhenAddindPlusOperand_ThenOperationIsNotPermettedAndExpressionNotChanged() {
        // MARK: - GIVEN
        
        // MARK: - WHEN
        XCTAssertFalse(oCalcModel.addOperator(with: .add))
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "")
    }
    
    func testGivenExpressionHas1PlusValue_WhenAddindPlusOperand_ThenOperationIsNotPermettedAndExpressionNotChanged() {
        // MARK: - GIVEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(oCalcModel.addOperator(with: .add))
        
        // MARK: - WHEN
        XCTAssertFalse(oCalcModel.addOperator(with: .add))
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "1 + ")
    }
    
    func testGivenExpressionIs1Plus2_WhenAskingResult_ThenExpressionIs1Plus2Equal3() {
        // MARK: - GIVEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(oCalcModel.addOperator(with: .add))
        XCTAssertTrue(oCalcModel.addDigit(digit: "2"))
        
        // MARK: - WHEN
        XCTAssertTrue(oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "1 + 2 = 3")
        
    }
    
    func testGivenExpressionIs2Minus1_WhenAskingResult_ThenExpressionIs2Minus1Equal1() {
        // MARK: - GIVEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(oCalcModel.addOperator(with: .subs))
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        
        // MARK: - WHEN
        XCTAssertTrue(oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "2 - 1 = 1")
        
    }
    
    func testGivenExpressionIs20Minus10_WhenAskingResult_ThenExpressionIs20Minus10Equal10() {
        // MARK: - GIVEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(oCalcModel.addOperator(with: .subs))
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(oCalcModel.addDigit(digit: "0"))
        
        // MARK: - WHEN
        XCTAssertTrue(oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "20 - 10 = 10")
        
    }
    
    func testGivenExpressionIs2Minus10_WhenAskingResult_ThenExpressionIs2Minus1EqualMinus8() {
        // MARK: - GIVEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(oCalcModel.addOperator(with: .subs))
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(oCalcModel.addDigit(digit: "0"))
        XCTAssertEqual(oCalcModel.getExpression(), "2 - 10")
        
        // MARK: - WHEN
        XCTAssertTrue(oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "2 - 10 = -8")
    }
    
    func testGivenExpressionIs2Minus_WhenAskingResult_ThenExpressionNotChangeAndIs2Minus() {
        // MARK: - GIVEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(oCalcModel.addOperator(with: .subs))
        
        // MARK: - WHEN
        XCTAssertFalse(oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "2 - ")
        
    }
    
    func testGivenExpressionIs2_WhenAskingResult_ThenExpressionNotChangeAndIs2() {
        // MARK: - GIVEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "2"))
        
        // MARK: - WHEN
        XCTAssertFalse(oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "2")
    }
    
    func testGivenExpressionIs10Minus1Plus_WhenAskingResult_ThenExpressionNotChangeAndIs10Minus1Plus() {
        // MARK: - GIVEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(oCalcModel.addOperator(with: .subs))
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(oCalcModel.addOperator(with: .add))

        // MARK: - WHEN
        XCTAssertFalse(oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "10 - 1 + ")
    }
    
    func testGivenExpressionIs10Minus1Plus2_WhenAskingResult_ThenExpressionIs10Minus1Plus2Equal11() {
        // MARK: - GIVEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(oCalcModel.addOperator(with: .subs))
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(oCalcModel.addOperator(with: .add))
        XCTAssertTrue(oCalcModel.addDigit(digit: "2"))

        // MARK: - WHEN
        XCTAssertTrue(oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "10 - 1 + 2 = 11")
    }
    
    func testGivenExpressionIs10Minus1Plus2_WhenEraseExpression_ThenExpressionIsEmpty() {
        // MARK: - GIVEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(oCalcModel.addOperator(with: .subs))
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(oCalcModel.addOperator(with: .add))
        XCTAssertTrue(oCalcModel.addDigit(digit: "2"))

        // MARK: - WHEN
        oCalcModel.eraseExpression()
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "")
    }
    
    func testGivenExpressionIs20Mult10_WhenAskingResult_ThenExpressionIs20Mult10Equal200() {
        // MARK: - GIVEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(oCalcModel.addOperator(with: .mult))
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(oCalcModel.addDigit(digit: "0"))
        
        // MARK: - WHEN
        XCTAssertTrue(oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "20 x 10 = 200")
        
    }
    
    func testGivenExpressionIs20Div10_WhenAskingResult_ThenExpressionIs20Div10Equal2() {
        // MARK: - GIVEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(oCalcModel.addOperator(with: .div))
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(oCalcModel.addDigit(digit: "0"))
        
        // MARK: - WHEN
        XCTAssertTrue(oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "20 ÷ 10 = 2")
        
    }
    
    func testGivenExpressionWithResult20Div10Equal2_WhenAddingDigit2_ThenExpressionIs2() {
        // MARK: - GIVEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(oCalcModel.addOperator(with: .div))
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(oCalcModel.calculateExpression())
        
        // MARK: - WHEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "2"))
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "2")
        
    }

    func testGivenExpressionWithResult20Div10Equal2_WhenAddingPlus_ThenExpressionIs2Plus() {
        // MARK: - GIVEN
        XCTAssertTrue(oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(oCalcModel.addOperator(with: .div))
        XCTAssertTrue(oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(oCalcModel.calculateExpression())
        
        // MARK: - WHEN
        XCTAssertTrue(oCalcModel.addOperator(with: .add))
        
        // MARK: - THEN
        XCTAssertEqual(oCalcModel.getExpression(), "2 + ")
        
    }
}
