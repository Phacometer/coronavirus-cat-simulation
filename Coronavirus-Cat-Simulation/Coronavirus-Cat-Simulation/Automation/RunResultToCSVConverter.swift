//
//  RunResultToCSVConverter.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-15.
//  Copyright © 2020 vgao. All rights reserved.
//

import Foundation

class RunResultToCSVConverter {
	class func csvString(from result: SimulationBatchRunOperation.Result) -> String {
		var csvString = "Cats Set Free,Total Infected,Still Susceptible"
		for batch in result.batches {
			for statistics in batch.infectionStatisticsForEveryRun {
				csvString += "\n\(batch.domesticCatSetFree),\(statistics.totalInfected),\(statistics.stillSusceptible)"
			}
		}
		return csvString
	}
}
