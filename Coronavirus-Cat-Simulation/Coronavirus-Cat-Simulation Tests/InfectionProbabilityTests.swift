//
//  InfectionProbabilityTests.swift
//  Coronavirus-Cat-Simulation Tests
//
//  Created by Victor Gao on 2020-04-06.
//  Copyright © 2020 vgao. All rights reserved.
//

import XCTest
@testable import Coronavirus_Cat_Simulation

class InfectionProbabilityTests: XCTestCase {
	
    func testInitWithOutOfRangeValues() {
		//Test with values below lower bound (which is zero).
		var probabilities = InfectionProbability(betweenPeople: .duringIncubation(-0.1, after: -0.2),
												 betweenCats: .duringIncubation(-0.1, after: -0.2),
												 betweenPersonAndCat: .duringIncubation(-0.1, after: -0.2))
		XCTAssertEqual(probabilities.betweenCats.afterIncubation, 0)
		XCTAssertEqual(probabilities.betweenCats.duringIncubation, 0)
		XCTAssertEqual(probabilities.betweenPeople.afterIncubation, 0)
		XCTAssertEqual(probabilities.betweenPeople.duringIncubation, 0)
		XCTAssertEqual(probabilities.betweenPersonAndCat.afterIncubation, 0)
		XCTAssertEqual(probabilities.betweenPersonAndCat.duringIncubation, 0)
		//Test values above upper bound (which is one)
		probabilities = InfectionProbability(betweenPeople: .duringIncubation(1.1, after: 1.2),
												 betweenCats: .duringIncubation(1.1, after: 1.2),
												 betweenPersonAndCat: .duringIncubation(1.1, after: 1.2))
		XCTAssertEqual(probabilities.betweenCats.afterIncubation, 1)
		XCTAssertEqual(probabilities.betweenCats.duringIncubation, 1)
		XCTAssertEqual(probabilities.betweenPeople.afterIncubation, 1)
		XCTAssertEqual(probabilities.betweenPeople.duringIncubation, 1)
		XCTAssertEqual(probabilities.betweenPersonAndCat.afterIncubation, 1)
		XCTAssertEqual(probabilities.betweenPersonAndCat.duringIncubation, 1)
    }
	
}
