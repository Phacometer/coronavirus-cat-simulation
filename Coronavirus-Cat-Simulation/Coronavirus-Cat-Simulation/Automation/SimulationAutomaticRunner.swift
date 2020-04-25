//
//  SimulationAutomaticRunOperation.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-13.
//  Copyright © 2020 vgao. All rights reserved.
//

import Foundation

protocol SimulationAutomaticRunnerDelegate: class {
	func reportProgress(_ progress: CGFloat)
	func reportSnapshotOfCurrentSimulationFrame(_ snapshot: EnvironmentSimulation.Snapshot)
	func oneSimulationDone()
	func oneBatchDone()
}

/// This class runs simulations automatically. The simulation runs are grouped into "batches". In each batch
/// the number of domestic cat to set free is different, all other variables are the same. The class runs
/// a number of simulations per batch, and returns the results as an instance of Result struct.
class SimulationAutomaticRunOperation: Operation {
	weak var delegate: SimulationAutomaticRunnerDelegate?
	
	private let settings: Environment.StartingSettings
	private let infectionProbabilities: InfectionProbability
	
	init(environmentSettings: Environment.StartingSettings, infectionProbabilities: InfectionProbability) {
		self.settings = environmentSettings
		self.infectionProbabilities = infectionProbabilities
	}
	
	func run(configuration: Configuration, completionHandler: @escaping (Result) -> ()) {
		DispatchQueue.global(qos: .background).async {
			var batches = [Batch]()
			for batchIndex in 0..<configuration.numberOfBatches {
				let batch = self.runBatch(batchIndex: batchIndex, configuration: configuration)
				batches.append(batch)
				DispatchQueue.main.async {
					self.delegate?.oneBatchDone()
				}
			}
			completionHandler(Result(batches: batches))
		}
	}
	
	func cancelRun() {
		
	}
	
	private func runBatch(batchIndex: Int, configuration: Configuration) -> Batch {
		let numCatsToSetFree = configuration.domesticCatsToSetFreeForEveryBatch[batchIndex]
		var statisticsForEveryRun = [InfectionStatistics]()
		for runIndex in 0..<configuration.numTimesToRunPerBatch {
			let statistics = runSimulationOnce(catsToSetFree: numCatsToSetFree,
											   framesToCompute: configuration.framesToRunBeforeGettingResult)
			statisticsForEveryRun.append(statistics)
			
			reportProgressToDelegate(batchIndex, runIndex, configuration)
		}
		return Batch(domesticCatSetFree: numCatsToSetFree, infectionStatisticsForEveryRun: statisticsForEveryRun)
	}
	
	private func reportProgressToDelegate(_ batchIndex: Int, _ runIndex: Int, _ configuration: Configuration) {
		let batchProgress = CGFloat(batchIndex) / CGFloat(configuration.numberOfBatches)
		let withinBatchProgress = CGFloat(runIndex + 1) / CGFloat(configuration.numTimesToRunPerBatch)
		DispatchQueue.main.async {
			self.delegate?.reportProgress(batchProgress
				+ withinBatchProgress * (1 / CGFloat(configuration.numberOfBatches)))
		}
	}
	
	private func runSimulationOnce(catsToSetFree: Int, framesToCompute: Int) -> InfectionStatistics {
		let simulation = EnvironmentSimulation(startingSettings: settings,
											   simulationParameters: EnvironmentSimulation.SimulationParameters(
												infectionProbabilities: infectionProbabilities,
												numberOfDomesticCatsToBeSetFree: catsToSetFree))
		while simulation.framesComputed < framesToCompute {
			let snapshot = simulation.snapshotOfCurrentFrame()
			DispatchQueue.main.async {
				self.delegate?.reportSnapshotOfCurrentSimulationFrame(snapshot)
			}
			simulation.computeNextFrame()
		}
		
		let snapshot = simulation.snapshotOfCurrentFrame()
		DispatchQueue.main.async {
			self.delegate?.reportSnapshotOfCurrentSimulationFrame(snapshot)
			self.delegate?.oneSimulationDone()
		}
		
		return tallyStatisticsFor(snapshot: snapshot)
	}
	
	private func tallyStatisticsFor(snapshot: EnvironmentSimulation.Snapshot) -> InfectionStatistics {
		let susceptibleCount = snapshot.persons.filter({ $0.state == .susceptible }).count
		let totalInfectedCount = snapshot.persons.count - susceptibleCount
		return InfectionStatistics(totalInfectedCount, susceptibleCount)
	}
}

extension SimulationAutomaticRunOperation {
	struct Configuration {
		let domesticCatsToSetFreeForEveryBatch: [Int]
		let numTimesToRunPerBatch: Int
		let framesToRunBeforeGettingResult: Int
		var numberOfBatches: Int {
			return domesticCatsToSetFreeForEveryBatch.count
		}
		
		static func config(domesticCatsToSetFreeForEveryBatch: [Int], numTimesToRunPerBatch: Int, framesToRunBeforeGettingResult: Int = 3000) -> Configuration {
			return Configuration(domesticCatsToSetFreeForEveryBatch: domesticCatsToSetFreeForEveryBatch,
								 numTimesToRunPerBatch: numTimesToRunPerBatch,
								 framesToRunBeforeGettingResult: framesToRunBeforeGettingResult)
		}
	}
}

extension SimulationAutomaticRunOperation {
	struct Result {
		let batches: [Batch]
	}
	
	struct Batch {
		let domesticCatSetFree: Int
		let infectionStatisticsForEveryRun: [InfectionStatistics]
	}
	
	typealias InfectionStatistics = (totalInfected: Int, stillSusceptible: Int)
}

extension SimulationAutomaticRunOperation {
	class RunOperation: Operation {
		
	}
}
