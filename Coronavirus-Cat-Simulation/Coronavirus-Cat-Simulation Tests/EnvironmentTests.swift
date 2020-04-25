//
//  EnvironmentTests.swift
//  Coronavirus-Cat-Simulation Tests
//
//  Created by Victor Gao on 2020-04-03.
//  Copyright © 2020 vgao. All rights reserved.
//

import XCTest
@testable import Coronavirus_Cat_Simulation

class EnvironmentTests: XCTestCase {
	
	let numberOfHouseholds = 50
	let householdSize = 3
	let percentageWithCats: CGFloat = 0.5
	let numWildCats = 100
	var settings: Environment.StartingSettings!

    override func setUpWithError() throws {
        settings = Environment.StartingSettings(spaceSideLength: 10000, numberOfHouseholds: numberOfHouseholds, householdSize: householdSize, percentageOfHouseholdsWithCats: percentageWithCats, numberOfWildCats: numWildCats)
    }

    func testInitStartingSettingsWithOutOfRangeValues() {
		var settings = Environment.StartingSettings(spaceSideLength: -100, numberOfHouseholds: -10, householdSize: 0, percentageOfHouseholdsWithCats: -0.1, numberOfWildCats: -100)
		XCTAssertEqual(settings.environmentSpaceSideLength, 0)
		XCTAssertEqual(settings.numberOfHouseholds, 0)
		XCTAssertEqual(settings.householdSize, 1)
		XCTAssertEqual(settings.percentageOfHouseholdsWithCats, 0)
		XCTAssertEqual(settings.numberOfWildCats, 0)
		settings = Environment.StartingSettings(spaceSideLength: 100, numberOfHouseholds: 10, householdSize: 1, percentageOfHouseholdsWithCats: 1.1, numberOfWildCats: 100)
		XCTAssertEqual(settings.percentageOfHouseholdsWithCats, 1)
    }
	
	func testInitEnvironment() {
		let environment = Environment(settings: settings)
		XCTAssertEqual(environment.households.count, numberOfHouseholds)
		XCTAssertEqual(environment.persons.count, householdSize * numberOfHouseholds)
		XCTAssertEqual(environment.domesticCats.count, Int(CGFloat(numberOfHouseholds) * percentageWithCats))
		XCTAssertEqual(environment.wildCats.count, numWildCats)
		XCTAssertEqual(environment.cats.count, environment.domesticCats.count + environment.wildCats.count)
		XCTAssertEqual(environment.agents.count, environment.cats.count + environment.persons.count)
	}
	
	func testEnvironmentAgentDelegateMethods() {
		let testPoint = CGPoint(x: -10, y: 10)
		let environment = Environment(settings: settings)
		XCTAssertTrue(environment.isPositionOutOfBounds(testPoint))
		XCTAssertEqual(environment.withinBoundsPosition(for: testPoint), CGPoint(x: 0, y: 10))
		let testPoint2 = CGPoint(x: 10, y: 10)
		XCTAssertFalse(environment.isPositionOutOfBounds(testPoint2))
		XCTAssertEqual(environment.withinBoundsPosition(for: testPoint2), testPoint2)
	}

}
