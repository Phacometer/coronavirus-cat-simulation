//
//  SimulationBatchRunOperationTests.swift
//  Coronavirus-Cat-Simulation Tests
//
//  Created by Victor Gao on 2020-04-13.
//  Copyright © 2020 vgao. All rights reserved.
//

import XCTest
@testable import Coronavirus_Cat_Simulation

class SimulationBatchRunOperationTests: XCTestCase, SimulationBatchRunOperationDelegate {
	
	let settings = Environment.StartingSettings(spaceSideLength: 150,
												numberOfHouseholds: 49,
												householdSize: 3,
												percentageOfHouseholdsWithCats: 0.2,
												numberOfWildCats: 30)
	let infectionProbabilities = InfectionProbability(betweenPeople: .duringIncubation(0.02, after: 0.05),
													  betweenCats: .duringIncubation(0.02, after: 0.05),
													  betweenPersonAndCat: .duringIncubation(0.01, after: 0.02))
	
	var expectations = [XCTestExpectation]()
	
	override func setUp() {
		expectations = []
	}

	func testOperation() {
		let queue = OperationQueue()
		let operation = SimulationBatchRunOperation(environmentSettings: settings, infectionProbabilities: infectionProbabilities, configuration: .config(domesticCatsToSetFreeForEveryBatch: [0, 1, 5], numTimesToRunPerBatch: 3, framesToRunBeforeGettingResult: 100))
		operation.delegate = self
		for expectationIndex in 0..<5 {
			expectations.append(XCTestExpectation(description: "Expectation #\(expectationIndex)"))
		}
		queue.addOperation(operation)
		wait(for: expectations, timeout: 30)
	}
	
	func secondsToSleepBeforeReportingProgress() -> Double {
		expectations[0].fulfill()
		return 0
	}
	
	func reportProgressOneSimulationDone(_ progress: CGFloat, simulationRunIndex: Int, currentBatchIndex: Int) {
		expectations[1].fulfill()
	}
	
	func reportCurrentSimulationFrame(_ snapshot: EnvironmentSimulation.Snapshot, framesComputed: Int) {
		expectations[2].fulfill()
	}
	
	func startingBatch(batchIndex: Int, numberOfCatsToSetFree: Int) {
		expectations[3].fulfill()
	}
	
	func simulationDone(result: SimulationBatchRunOperation.Result) {
		expectations[4].fulfill()
	}

}
