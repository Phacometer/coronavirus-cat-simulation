//
//  SimulationBatchRunOperation.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-13.
//  Copyright © 2020 vgao. All rights reserved.
//

import Foundation

protocol SimulationBatchRunOperationDelegate: class {
	/// This method is not called on the main thread. Return a non-zero value to give "breathing time"
	/// before progress is reported. You can use the "breathing time" to ensure that all UI is updated,
	/// for example.
	func secondsToSleepBeforeReportingProgress() -> Double
	func reportProgressOneSimulationDone(_ progress: CGFloat, simulationRunIndex: Int, currentBatchIndex: Int)
	func reportCurrentSimulationFrame(_ snapshot: EnvironmentSimulation.Snapshot, framesComputed: Int)
	func startingBatch(batchIndex: Int, numberOfCatsToSetFree: Int)
	func simulationDone(result: SimulationBatchRunOperation.Result)
}

/// This class is an operation that runs simulations in batches. It is part of the automation functionality of the
/// application.
class SimulationBatchRunOperation: Operation {
	weak var delegate: SimulationBatchRunOperationDelegate?
	
	let settings: Environment.StartingSettings
	let infectionProbabilities: InfectionProbability
	let configuration: Configuration
	
	init(environmentSettings: Environment.StartingSettings,
		 infectionProbabilities: InfectionProbability,
		 configuration: Configuration) {
		self.settings = environmentSettings
		self.infectionProbabilities = infectionProbabilities
		self.configuration = configuration
	}
	
	override func main() {
		//Run simulation automatically in batches
		var batches = [Batch]()
		for batchIndex in 0..<configuration.numberOfBatches {
			if isCancelled {
				return
			}
			DispatchQueue.main.async {
				self.delegate?.startingBatch(batchIndex: batchIndex, numberOfCatsToSetFree: self.configuration.domesticCatsToSetFreeForEveryBatch[batchIndex])
			}
			let batch = runBatch(batchIndex: batchIndex)
			batches.append(batch)
		}
		DispatchQueue.main.async {
			self.delegate?.simulationDone(result: Result(batches: batches))
		}
	}
	
	private func runBatch(batchIndex: Int) -> Batch {
		let numCatsToSetFree = configuration.domesticCatsToSetFreeForEveryBatch[batchIndex]
		var statisticsForEveryRun = [InfectionStatistics]()
		for runIndex in 0..<configuration.numTimesToRunPerBatch {
			if isCancelled {
				//Return empty object if cancelled
				return Batch(domesticCatSetFree: 0, infectionStatisticsForEveryRun: [])
			}
			let statistics = runSimulationOnce(catsToSetFree: numCatsToSetFree)
			statisticsForEveryRun.append(statistics)
			
			if let seconds = delegate?.secondsToSleepBeforeReportingProgress() {
				usleep(UInt32(seconds * 1000000))
			}
			reportProgressToDelegate(batchIndex, runIndex)
		}
		return Batch(domesticCatSetFree: numCatsToSetFree, infectionStatisticsForEveryRun: statisticsForEveryRun)
	}
	
	private func reportProgressToDelegate(_ batchIndex: Int, _ runIndex: Int) {
		let batchProgress = CGFloat(batchIndex) / CGFloat(configuration.numberOfBatches)
		let withinBatchProgress = CGFloat(runIndex + 1) / CGFloat(configuration.numTimesToRunPerBatch)
		DispatchQueue.main.async {
			let progress = batchProgress + withinBatchProgress * (1 / CGFloat(self.configuration.numberOfBatches))
			self.delegate?.reportProgressOneSimulationDone(progress, simulationRunIndex: runIndex, currentBatchIndex: batchIndex)
		}
	}
	
	private func runSimulationOnce(catsToSetFree: Int) -> InfectionStatistics {
		let simulation = EnvironmentSimulation(startingSettings: settings,
											   simulationParameters: EnvironmentSimulation.SimulationParameters(
												infectionProbabilities: infectionProbabilities,
												numberOfDomesticCatsToBeSetFree: catsToSetFree))
		while simulation.framesComputed < configuration.framesToRunBeforeGettingResult {
			if isCancelled {
				//Return empty tuple if cancelled
				return (0, 0)
			}
			let snapshot = simulation.snapshotOfCurrentFrame()
			DispatchQueue.main.async {
				self.delegate?.reportCurrentSimulationFrame(snapshot, framesComputed: simulation.framesComputed)
			}
			simulation.computeNextFrame()
		}
		
		let snapshot = simulation.snapshotOfCurrentFrame()
		DispatchQueue.main.async {
			//Report the final frame.
			self.delegate?.reportCurrentSimulationFrame(snapshot, framesComputed: simulation.framesComputed)
		}
		return tallyStatisticsFor(snapshot: snapshot)
	}
	
	private func tallyStatisticsFor(snapshot: EnvironmentSimulation.Snapshot) -> InfectionStatistics {
		let susceptibleCount = snapshot.persons.filter({ $0.state == .susceptible }).count
		let totalInfectedCount = snapshot.persons.count - susceptibleCount
		return InfectionStatistics(totalInfectedCount, susceptibleCount)
	}
}

extension SimulationBatchRunOperation {
	struct Configuration {
		let domesticCatsToSetFreeForEveryBatch: [Int]
		let numTimesToRunPerBatch: Int
		let framesToRunBeforeGettingResult: Int
		var numberOfBatches: Int {
			return domesticCatsToSetFreeForEveryBatch.count
		}
		
		static func config(domesticCatsToSetFreeForEveryBatch: [Int], numTimesToRunPerBatch: Int, framesToRunBeforeGettingResult: Int = 3214) -> Configuration {
			return Configuration(domesticCatsToSetFreeForEveryBatch: domesticCatsToSetFreeForEveryBatch,
								 numTimesToRunPerBatch: numTimesToRunPerBatch,
								 framesToRunBeforeGettingResult: framesToRunBeforeGettingResult)
		}
	}
}

extension SimulationBatchRunOperation {
	struct Result {
		let batches: [Batch]
	}
	
	struct Batch {
		let domesticCatSetFree: Int
		let infectionStatisticsForEveryRun: [InfectionStatistics]
	}
	
	typealias InfectionStatistics = (totalInfected: Int, stillSusceptible: Int)
}
