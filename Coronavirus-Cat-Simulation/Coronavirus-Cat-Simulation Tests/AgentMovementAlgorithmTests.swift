//
//  AgentMovementAlgorithmTests.swift
//  Coronavirus-Cat-Simulation Tests
//
//  Created by Victor Gao on 2020-04-03.
//  Copyright © 2020 vgao. All rights reserved.
//

import XCTest
@testable import Coronavirus_Cat_Simulation

class AgentMovementAlgorithmTests: XCTestCase {
	
	var algorithm: AgentMovementAlgorithm!

    override func setUpWithError() throws {
        algorithm = AgentMovementAlgorithm()
    }

    func testSetMaximumTurningAngle() {
		algorithm.maximumTurningAngle = 2*CGFloat.pi
		XCTAssertEqual(algorithm.maximumTurningAngle, CGFloat.pi)	//The maximum allowed value is CGFloat.pi
		algorithm.maximumTurningAngle = -1
		XCTAssertEqual(algorithm.maximumTurningAngle, 1)	//Cannot be negative
    }
	
	func testMoveDistance() {
		for distance in 3...10 {
			algorithm.distanceOfEachMovement = CGFloat(distance)
			for _ in 0..<1000 {
				let previous = CGPoint.zero
				let current = algorithm.calculateNewPosition(from: previous)
				XCTAssertEqual(sqrt(pow(current.x - previous.x, 2) + pow(current.y - previous.y, 2)).rounded(), CGFloat(distance))
			}
		}
	}
	
	func testChangeDirection() {
		var previousPoint = CGPoint.zero
		for numTimes in 1...10 {
			algorithm.numberOfTimesToCalculateBeforeSwitchingDirection = numTimes
			var previousDirection: CGFloat = 0
			for i in 1...numTimes*10+1 {
				let point = algorithm.calculateNewPosition(from: previousPoint)
				var direction = atan((point.y - previousPoint.y) / (point.x - previousPoint.x))
				//Round to fifth decimal place to ignore figures that are insignificant
				direction = ((direction*100000).rounded()) / 100000
				if (i-1) % numTimes == 0 {
					//Test if algorithm changed direction after every numTimes
					XCTAssertNotEqual(direction, previousDirection)
				} else if i != 1 {
					//Test if direction is not changed if i is not 1, because when i is one,
					//previousDirection is not yet set to correct value (it is set to a placeholder value of 0).
					XCTAssertEqual(direction, previousDirection)
				}
				previousPoint = point
				previousDirection = direction
			}
			algorithm.reset()
		}
	}
	
	func testAlgorithmResetDirection() {
		let referencePosition = CGPoint.zero
		let newPosition1 = algorithm.calculateNewPosition(from: referencePosition)
		let direction1 = atan((newPosition1.y - referencePosition.y) / (newPosition1.x - referencePosition.x))
		algorithm.reset()
		let newPosition2 = algorithm.calculateNewPosition(from: referencePosition)
		let direction2 = atan((newPosition2.y - referencePosition.y) / (newPosition2.x - referencePosition.x))
		XCTAssertNotEqual(direction1, direction2)
	}

}
