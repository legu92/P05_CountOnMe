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

    func testGiven_WhenAskForCalcModel_ThenCalcModelExists() {
        let oCalcModel = CalcModel()
        
        XCTAssertNotNil(oCalcModel)
    }

}
