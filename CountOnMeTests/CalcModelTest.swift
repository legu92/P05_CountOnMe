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
    let iMaxWholePart: Int = 5
    let iPrecisionPart: Int = 3
    
    override func setUp() {
        super.setUp()

        self.oCalcModel = CalcModel(decimalPrecision: self.iPrecisionPart, maxDigitForWholePart: self.iMaxWholePart)
    }
    
    func testGivenCalcModelJustCreated_WhenAskingForExpression_ThenExpressionIsAEmptyString() {
        // MARK: - GIVEN
        
        
        // MARK: - WHEN
        let szExpresion = self.oCalcModel.getExpression()
        
        // MARK: - THEN
        XCTAssertNotNil(szExpresion)
        XCTAssertEqual("",szExpresion)
        XCTAssertTrue(self.oCalcModel.bExpressionIsEmpty)
        
    }
    
    func testGivenExpressionIsEmpty_WhenAddingADigit_ThenExpressionContainJustTheDigit() {
        // MARK: - GIVEN
        
        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "1")
    }
    
    func testGivenExpressionHave1value_WhenAddingADigit2_ThenExpressionContains12() {
        // MARK: - GIVEN
        XCTAssertTrue(self.self.oCalcModel.addDigit(digit: "1"))
        
        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "12")
    }
    
    func testGivenExpressionHave1value_WhenAddingANonDigit_ThenExpressionContains1() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        
        // MARK: - WHEN
        XCTAssertFalse(self.oCalcModel.addDigit(digit: "h"))
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "1")
    }
    
    func testGivenExpressionHave1value_WhenAdding2Digits_ThenExpressionContains1() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        
        // MARK: - WHEN
        XCTAssertFalse(self.oCalcModel.addDigit(digit: "12"))
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "1")
    }
    
    func testGivenExpressionHave1value_WhenAdding0Digit_ThenExpressionContains1() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        
        // MARK: - WHEN
        XCTAssertFalse(self.oCalcModel.addDigit(digit: ""))
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "1")
    }
    
    func testGivenExpressionHave1Plusvalue_WhenAdding2AsDigit_ThenExpressionContains1Plus2() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .add))
        
        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "1 + 2")
    }
    
    func testGivenExpressionHaveNovalue_WhenAddindPlusOperand_ThenOperationIsNotPermettedAndExpressionNotChanged() {
        // MARK: - GIVEN
        
        // MARK: - WHEN
        XCTAssertFalse(self.oCalcModel.addOperator(with: .add))
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "")
    }
    
    func testGivenExpressionHas1PlusValue_WhenAddindPlusOperand_ThenOperationIsNotPermettedAndExpressionNotChanged() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .add))
        
        // MARK: - WHEN
        XCTAssertFalse(self.oCalcModel.addOperator(with: .add))
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "1 + ")
    }
    
    func testGivenExpressionIs1Plus2_WhenAskingResult_ThenExpressionIs1Plus2Equal3() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .add))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        
        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "1 + 2 = 3")
        
    }
    
    func testGivenExpressionIs2Minus1_WhenAskingResult_ThenExpressionIs2Minus1Equal1() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .subs))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        
        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "2 - 1 = 1")
        
    }
    
    func testGivenExpressionIs20Minus10_WhenAskingResult_ThenExpressionIs20Minus10Equal10() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .subs))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "0"))
        
        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "20 - 10 = 10")
        
    }
    
    func testGivenExpressionIs2Minus10_WhenAskingResult_ThenExpressionIs2Minus1EqualMinus8() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .subs))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "0"))
        XCTAssertEqual(self.oCalcModel.getExpression(), "2 - 10")
        
        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "2 - 10 = -8")
    }
    
    func testGivenExpressionIs2Minus_WhenAskingResult_ThenExpressionNotChangeAndIs2Minus() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .subs))
        
        // MARK: - WHEN
        XCTAssertFalse(self.oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "2 - ")
        
    }
    
    func testGivenExpressionIs2_WhenAskingResult_ThenExpressionNotChangeAndIs2() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        
        // MARK: - WHEN
        XCTAssertFalse(self.oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "2")
    }
    
    func testGivenExpressionIs10Minus1Plus_WhenAskingResult_ThenExpressionNotChangeAndIs10Minus1Plus() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .subs))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .add))

        // MARK: - WHEN
        XCTAssertFalse(self.oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "10 - 1 + ")
    }
    
    func testGivenExpressionIs10Minus1Plus2_WhenAskingResult_ThenExpressionIs10Minus1Plus2Equal11() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .subs))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .add))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))

        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "10 - 1 + 2 = 11")
    }
    
    func testGivenExpressionIs10Minus1Plus2_WhenEraseExpression_ThenExpressionIsEmpty() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .subs))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .add))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))

        // MARK: - WHEN
        self.oCalcModel.eraseExpression()
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "")
    }
    
    func testGivenExpressionIs20Mult10_WhenAskingResult_ThenExpressionIs20Mult10Equal200() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .mult))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "0"))
        
        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "20 x 10 = 200")
        
    }
    
    func testGivenExpressionIs20Div10_WhenAskingResult_ThenExpressionIs20Div10Equal2() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .div))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "0"))
        
        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "20 ÷ 10 = 2")
        
    }
    
    func testGivenExpressionWithResult20Div10Equal2_WhenAddingDigit2_ThenExpressionIs2() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .div))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(self.oCalcModel.calculateExpression())
        
        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "2")
        
    }

    func testGivenExpressionWithResult20Div10Equal2_WhenAddingPlus_ThenExpressionIs2Plus() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .div))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(self.oCalcModel.calculateExpression())
        
        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.addOperator(with: .add))
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "2 + ")
    }
   
    func testGivenExpressionWithResult20Div10Equal2_WhenAddingDigit1_ThenExpressionIs1() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .div))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "0"))
        XCTAssertTrue(self.oCalcModel.calculateExpression())
        
        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "1")
    }

    
    func testGivenExpressionIs2Comma_WhenAdding1_ThenExpressionIs2Comma1() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(self.oCalcModel.addDecimalSeparator())
        
        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "2.1")
    }
    
    func testGivenExpressionIs2Comma1_WhenAddingComma_ThenExpressionIs2Comma1() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(self.oCalcModel.addDecimalSeparator())
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        
        // MARK: - WHEN
        XCTAssertFalse(self.oCalcModel.addDecimalSeparator())
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "2.1")
    }
    
    func testGivenExpressionIs2Comma1Plus1_WhenCalculating_ThenExpressionIs2Comma1Plus1Equal3Comma1() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(self.oCalcModel.addDecimalSeparator())
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .add))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))

        
        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "2.1 + 1 = 3.1")
    }
    
    func testGivenExpressionIs2Comma_WhenAddingComma_ThenExpressionNotChangeAndIs2Comma() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(self.oCalcModel.addDecimalSeparator())
        
        // MARK: - WHEN
        XCTAssertFalse(self.oCalcModel.addDecimalSeparator())
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "2.")
    }
    
    func testGivenExpressionIsCalculated_WhenAddingComma_ThenExpressionNotChanged() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .add))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.calculateExpression())
        
        // MARK: - WHEN
        XCTAssertFalse(self.oCalcModel.addDecimalSeparator())
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "1 + 1 = 2")
    }
    
    func testGivenExpressionIsEmpty_WhenAddingComma_ThenExpressionStillEmpty() {
        // MARK: - GIVEN
        
        // MARK: - WHEN
        XCTAssertFalse(self.oCalcModel.addDecimalSeparator())
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "")
    }
    
    func testGivenExpression2Plus_WhenAddingComma_ThenExpressionTheSame() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .add))
        let szCurrentExpression = oCalcModel.getExpression()
        
        // MARK: - WHEN
        XCTAssertFalse(self.oCalcModel.addDecimalSeparator())
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), szCurrentExpression)
    }
    
    func testGiven2Comma1Mult18Comma8_WhenCalculate_ThenExpressionIs2Comma1Mult18Comma8Equal39Comma48() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(self.oCalcModel.addDecimalSeparator())
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .mult))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "8"))
        XCTAssertTrue(self.oCalcModel.addDecimalSeparator())
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "8"))

        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "2.1 x 18.8 = 39.48")
    }

    func testGiven4Comma5Div3_WhenCalculate_ThenExpressionIs4Comma5Div3Equal1Comma5() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "4"))
        XCTAssertTrue(self.oCalcModel.addDecimalSeparator())
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "5"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .div))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "3"))

        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "4.5 ÷ 3 = 1.5")
    }

    func testGiven5Div3_WhenCalculate_ThenExpressionIs5Div3Equal1Comma666666667() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "5"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .div))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "3"))

        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.calculateExpression())
        
        // MARK: - THEN
        let szResultAttendu = "1.666666666666666666666666666666666666666".prefix(2 + self.iPrecisionPart - 1) + "7"
        XCTAssertEqual(self.oCalcModel.getExpression(), "5 ÷ 3 = " + szResultAttendu)
    }
    
    func testGiven1Div3_WhenCalculate_ThenExpressionIs1Div3Equal0Comma33333333() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .div))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "3"))

        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.calculateExpression())
        
        // MARK: - THEN
        let szResultAttendu = "0.333333333333333333333333333333333333333333".prefix(2 + self.iPrecisionPart)
        XCTAssertEqual(self.oCalcModel.getExpression(), "1 ÷ 3 = " + szResultAttendu)
    }
    
    func testGiven5Div0_WhenCalculate_ThenAnErrorAppear() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "5"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .div))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "0"))

        // MARK: - WHEN
        XCTAssertFalse(self.oCalcModel.calculateExpression())
        
        // MARK: - THEN
    }
    
    func testGiven5Comma12345678_WhenAddingDigit_ThenExpressionIs5Comma12345678() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "5"))
        XCTAssertTrue(self.oCalcModel.addDecimalSeparator())
        XCTAssertTrue(fillWithMaxDecimalPrecision())
        let szPreviousExpression = self.oCalcModel.getExpression()

        // MARK: - WHEN
        XCTAssertFalse(self.oCalcModel.addDigit(digit: "9"))
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), szPreviousExpression)
    }
    
    func testGivenExpressionHasMaxSizeWholePartIntegerMinus1_WhenAddingDigit_ThenExpressionHasAddedTheDigit() {
        var szResultExpected: String = ""

        // MARK: - GIVEN
        for iLoop in 1...self.iMaxWholePart - 1 {
            XCTAssertTrue(self.oCalcModel.addDigit(digit: String(iLoop%10)))
            szResultExpected += String(iLoop%10)
        }

        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "7"))
        szResultExpected += "7"
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), szResultExpected)
    }

    func testGivenExpressionHasMaxSizeWholePartInteger_WhenAddingDigit_ThenExpressionIsNotChanged() {
        // MARK: - GIVEN
        var szResultExpected: String = ""

        // MARK: - GIVEN
        for iLoop in 1...self.iMaxWholePart {
            XCTAssertTrue(self.oCalcModel.addDigit(digit: String(iLoop%10)))
            szResultExpected += String(iLoop%10)
        }

        // MARK: - WHEN
        XCTAssertFalse(self.oCalcModel.addDigit(digit: "7"))

        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), szResultExpected)
    }


    
    func testGivenSeveralString_WhenAskingForPrecisionAndNumberOfDigit_ThenTheAnswerIs7And4() {
        // MARK: - GIVEN
        let szItem = "1812.1234567"
        
        // MARK: - THEN
        XCTAssertEqual(CalcModel.getPrecision(forItem: szItem), 7)
        XCTAssertEqual(CalcModel.getNumberDigitEntirePart(forItem: szItem), 4)
        
        XCTAssertEqual(CalcModel.getNumberDigitEntirePart(forItem: ""), 0)
        XCTAssertEqual(CalcModel.getPrecision(forItem: ""), 0)
        
        XCTAssertEqual(CalcModel.getNumberDigitEntirePart(forItem: "189"), 3)
        XCTAssertEqual(CalcModel.getPrecision(forItem: "189"), 0)

        XCTAssertEqual(CalcModel.getNumberDigitEntirePart(forItem: "+"), -1)
        XCTAssertEqual(CalcModel.getPrecision(forItem: "+"), -1)

        XCTAssertEqual(CalcModel.getNumberDigitEntirePart(forItem: "dfdfg121fg."), -1)
        XCTAssertEqual(CalcModel.getPrecision(forItem: "dfdfg121fg."), -1)

        XCTAssertEqual(CalcModel.getNumberDigitEntirePart(forItem: "189."), 3)
        XCTAssertEqual(CalcModel.getPrecision(forItem: "189."), 0)

    }
    
    func testGivenExpressionIsMaxMinus1Capacity_WhenAdding1_thenCalculateIsOverflow() {
        // MARK: - GIVEN
        for _ in 1...self.iMaxWholePart {
            XCTAssertTrue(self.oCalcModel.addDigit(digit: "9"))
        }
        
        // MARK: - WHEN
        XCTAssertTrue(self.oCalcModel.addOperator(with: .add))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        
        // MARK: - THEN
        XCTAssertFalse(self.oCalcModel.calculateExpression())
        
    }
    
    func testGivenExpressionWithPlusOperatorAndMultOperotor_WhenCalculate_thenPriorisationIsOnMult() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .add))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .mult))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "3"))
        
        // MARK: - WHEN

        XCTAssertTrue(self.oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "1 + 2 x 3 = 7")
        
    }

    func testGivenExpressionWithPriorityOperator_WhenCalculate_thenPriorisationIsApplied() {
        // MARK: - GIVEN
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "1"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .add))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .mult))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "3"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .div))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "2"))
        XCTAssertTrue(self.oCalcModel.addOperator(with: .subs))
        XCTAssertTrue(self.oCalcModel.addDigit(digit: "9"))


        // MARK: - WHEN

        XCTAssertTrue(self.oCalcModel.calculateExpression())
        
        // MARK: - THEN
        XCTAssertEqual(self.oCalcModel.getExpression(), "1 + 2 x 3 ÷ 2 - 9 = -5")
        
    }

    private func fillWithMaxDecimalPrecision() -> Bool {
        for iLoop in 1...self.iPrecisionPart {
            if !self.oCalcModel.addDigit(digit: String(iLoop)) {
                return false
            }
        }
        return true
    }

}
