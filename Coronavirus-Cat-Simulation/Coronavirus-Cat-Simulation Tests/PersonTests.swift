//
//  PersonTests.swift
//  Coronavirus-Cat-Simulation Tests
//
//  Created by Victor Gao on 2020-04-02.
//  Copyright © 2020 vgao. All rights reserved.
//

import XCTest
@testable import Coronavirus_Cat_Simulation

class PersonTests: XCTestCase, AgentDelegate {
	
	var person: Person!
	let environmentSideLength: CGFloat = 100
	
	// MARK: AgentDelegate
	
	func isPositionOutOfBounds(_ position: CGPoint) -> Bool {
		return position.x < 0 || position.x > environmentSideLength || position.y < 0 || position.y > environmentSideLength
	}
	
	func withinBoundsPosition(for position: CGPoint) -> CGPoint {
		var newPosition = position
		newPosition.x = max(0, newPosition.x)
		newPosition.x = min(environmentSideLength, newPosition.x)
		newPosition.y = max(0, newPosition.y)
		newPosition.y = min(environmentSideLength, newPosition.y)
		return newPosition
	}
	
	// MARK: Testing code
	
	override func setUp() {
		person = Person(household: Household(positionOfHouse: CGPoint(x: environmentSideLength / 2,
																	  y: environmentSideLength / 2)))
	}

    func testPersonInit() {
        let position = CGPoint(x: 5, y: 10)	//Some arbitrary position
		let person = Person(household: Household(positionOfHouse: position))
		XCTAssertEqual(person.household.positionOfHouse, position)
		XCTAssertEqual(person.position, position)
		XCTAssertEqual(person.state, DiseaseState.susceptible)
    }
	
	func testPersonSetState() {
		person.state = .infected
		XCTAssertEqual(person.state, DiseaseState.infected)
		person.state = .removed
		XCTAssertEqual(person.state, DiseaseState.removed)
	}
	
	func testPersonSetDelegate() {
		person.delegate = self
		XCTAssertTrue(person.delegate != nil)
	}
	
	func testPersonSetAverageWalkLength() {
		let testFloat: Int = -100
		person.averageWalkDuration = testFloat
		XCTAssertEqual(person.averageWalkDuration, abs(testFloat))
	}
	
	func testPersonMoveOnce() {
		person.delegate = self
		let previousPosition = person.position
		person.move()
		XCTAssertNotEqual(person.position, previousPosition)
	}
	
	func testPersonMoveAwayFromThenSuccessfullyBackToHouse() {
		var numTimesMoved: Int = 0
		person.averageWalkDuration = 1000
		person.delegate = self
		repeat {
			person.move()
			XCTAssertFalse(isPositionOutOfBounds(person.position), "Position: \(person.position)")
			numTimesMoved += 1
		} while !person.isAtHouse && numTimesMoved < person.averageWalkDuration + 50
		XCTAssertEqual(person.isAtHouse, true)
		XCTAssertEqual(person.position, person.household.positionOfHouse)
		print(numTimesMoved)
	}

}
