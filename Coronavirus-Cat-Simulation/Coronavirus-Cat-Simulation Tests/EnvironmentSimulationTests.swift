//
//  EnvironmentSimulationTests.swift
//  Coronavirus-Cat-Simulation Tests
//
//  Created by Victor Gao on 2020-04-04.
//  Copyright © 2020 vgao. All rights reserved.
//

import XCTest
@testable import Coronavirus_Cat_Simulation

class EnvironmentSimulationTests: XCTestCase {
	
	let startingSettings = Environment.StartingSettings(spaceSideLength: 10000,
														numberOfHouseholds: 20,
														householdSize: 3,
														percentageOfHouseholdsWithCats: 0.25,
														numberOfWildCats: 30)
	let infectionProbabilities = InfectionProbability(betweenPeople: .duringIncubation(0.2, after: 0.5),
													  betweenCats: .duringIncubation(0.1, after: 0.2),
													  betweenPersonAndCat: .duringIncubation(0.05, after: 0.06))
	var parameters: EnvironmentSimulation.SimulationParameters!
	var environmentSimulation: EnvironmentSimulation!

	override func setUp() {
		parameters = EnvironmentSimulation.SimulationParameters(infectionProbabilities: infectionProbabilities, numberOfDomesticCatsToBeSetFree: 5)
		environmentSimulation = EnvironmentSimulation(startingSettings: startingSettings, simulationParameters: parameters)
	}

    func testInitSimulationParametersWithOutOfRangeValues() {
		let parameters = EnvironmentSimulation.SimulationParameters(infectionProbabilities: infectionProbabilities,
																	numberOfDomesticCatsToBeSetFree: -1)
		XCTAssertEqual(parameters.numberOfDomesticCatsToBeSetFree, 0)
    }
	
	func testGetSimulationSnapshot() {
		let snapshot = environmentSimulation.snapshotOfCurrentFrame()
		XCTAssertEqual(snapshot.environmentDimensions.width, startingSettings.environmentSpaceSideLength)
		XCTAssertEqual(snapshot.environmentDimensions.height, startingSettings.environmentSpaceSideLength)
		XCTAssertNotEqual(snapshot.persons.count, 0)
		XCTAssertNotEqual(snapshot.cats.count, 0)
		XCTAssertEqual(snapshot.householdPositions.count, startingSettings.numberOfHouseholds)
	}
	
	func testSetParameters() {
		let newParameters = EnvironmentSimulation.SimulationParameters(infectionProbabilities: infectionProbabilities, numberOfDomesticCatsToBeSetFree: 100)
		environmentSimulation.parameters = newParameters
		XCTAssertEqual(environmentSimulation.parameters.numberOfDomesticCatsToBeSetFree,
					   newParameters.numberOfDomesticCatsToBeSetFree)
	}
	
	func testGetInitialSnapshot() {
		let snapshot = environmentSimulation.snapshotOfCurrentFrame()
		let desiredNumberOfCats = startingSettings.numberOfWildCats + Int(CGFloat(startingSettings.numberOfHouseholds) * startingSettings.percentageOfHouseholdsWithCats)
		XCTAssertEqual(snapshot.cats.count, desiredNumberOfCats)
		XCTAssertEqual(snapshot.householdPositions.count, startingSettings.numberOfHouseholds)
		XCTAssertEqual(snapshot.persons.count, startingSettings.numberOfHouseholds * startingSettings.householdSize)
		XCTAssertEqual(snapshot.environmentDimensions.width, startingSettings.environmentSpaceSideLength)
		XCTAssertEqual(snapshot.environmentDimensions.height, startingSettings.environmentSpaceSideLength)
	}
	
	func testComputeNextFrameOnce() {
		environmentSimulation.computeNextFrame()
	}
	
	func testOnePersonDidLeaveHouse() {
		let framesToComputeForOnePersonLeaveHouse = parameters.framesPerOnePersonLeavingHouse
		var noPersonLeftHouse = true
		self.measure {
			for _ in 0..<framesToComputeForOnePersonLeaveHouse {
				self.environmentSimulation.computeNextFrame()
				let snapshot = self.environmentSimulation.snapshotOfCurrentFrame()
				for person in snapshot.persons {
					for householdPosition in snapshot.householdPositions {
						if person.position != householdPosition {
							noPersonLeftHouse = false
						}
					}
				}
			}
		}
		XCTAssertEqual(noPersonLeftHouse, false)
	}

}
