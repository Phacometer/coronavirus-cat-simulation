//
//  CatTests.swift
//  Coronavirus-Cat-Simulation Tests
//
//  Created by Victor Gao on 2020-04-02.
//  Copyright © 2020 vgao. All rights reserved.
//

import XCTest
@testable import Coronavirus_Cat_Simulation

class CatTests: XCTestCase, AgentDelegate {
	
	var wildCat: Cat!
	var domesticCat: Cat!
	var environmentSideLength: CGFloat = 100
	
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
		let position = CGPoint(x: environmentSideLength / 2, y: environmentSideLength / 2)
		wildCat = Cat.wildCat(atPosition: position)
		domesticCat = Cat.domesticCat(ofHousehold: Household(positionOfHouse: position))
	}

    func testInitDomesticCat() {
		let position = CGPoint(x: 50, y: 50)
		let cat = Cat.domesticCat(ofHousehold: Household(positionOfHouse: position))
		XCTAssertEqual(cat.position, position)
		XCTAssertNotNil(cat.household)
		XCTAssertEqual(cat.type, Cat.CatType.domestic)
    }
	
	func testInitWildCat() {
		let position = CGPoint(x: 50, y: 50)
		let cat = Cat.wildCat(atPosition: position)
		XCTAssertEqual(cat.position, position)
		XCTAssertNil(cat.household)
		XCTAssertEqual(cat.type, Cat.CatType.wild)
	}
	
	func testCatSetState() {
		wildCat.state = .infected
		XCTAssertEqual(wildCat.state, DiseaseState.infected)
		wildCat.state = .removed
		XCTAssertEqual(wildCat.state, DiseaseState.removed)
	}
	
	func testDomesticCatMove() {
		let previousPosition = domesticCat.position
		domesticCat.move()
		XCTAssertEqual(previousPosition, domesticCat.position)	//Domestic cats can't move
	}
	
	func testDomesticCatSetFree() {
		domesticCat.setFree()
		XCTAssertNil(domesticCat.household)
		XCTAssertEqual(domesticCat.type, Cat.CatType.domesticSetFree)
	}
	
	func testCatSetDelegate() {
		wildCat.delegate = self
		XCTAssertNotNil(wildCat.delegate)
		domesticCat.delegate = self
		XCTAssertNotNil(domesticCat.delegate)
	}
	
	func testWildCatMove() {
		wildCat.delegate = self
		var previousPosition = wildCat.position
		for _ in 0..<10000 {
			wildCat.move()
			let catDidNotMoveAndDidNotReachBorders = wildCat.position == previousPosition && (wildCat.position.x > 0 && wildCat.position.x < environmentSideLength) && (wildCat.position.y > 0 && wildCat.position.y < environmentSideLength)
			XCTAssertFalse(catDidNotMoveAndDidNotReachBorders, "wildCat did not move! Position: \(wildCat.position), previous position: \(previousPosition)")
			XCTAssertFalse(isPositionOutOfBounds(wildCat.position))
			previousPosition = wildCat.position
		}
	}

}
