//
//  SimulationVariables.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-15.
//  Copyright © 2020 vgao. All rights reserved.
//

import Foundation

//
// This file collects almost all of the variables in the simulation in one place.
// A variable is a setting or parameter that can be set to change how the simulation is run.
//

extension Environment {
	struct StartingSettings {
		let environmentSpaceSideLength: CGFloat
		let numberOfHouseholds: Int
		let householdSize: Int
		let percentageOfHouseholdsWithCats: CGFloat
		let numberOfWildCats: Int
		let numberOfInfectedPersons: Int
		
		init(spaceSideLength: CGFloat, numberOfHouseholds: Int, householdSize: Int, percentageOfHouseholdsWithCats: CGFloat, numberOfWildCats: Int, numberOfInfectedPersons: Int = 1) {
			self.environmentSpaceSideLength = max(0, spaceSideLength)
			self.numberOfHouseholds = max(0, numberOfHouseholds)
			self.householdSize = max(1, householdSize)
			self.percentageOfHouseholdsWithCats = min(max(0, percentageOfHouseholdsWithCats), 1)
			self.numberOfWildCats = max(0, numberOfWildCats)
			self.numberOfInfectedPersons = numberOfInfectedPersons
		}
	}
}

extension EnvironmentSimulation {
	/// Contains parameters relating to the execution of the simulation.
	struct SimulationParameters {
		let infectionProbabilities: InfectionProbability
		
		let numberOfDomesticCatsToBeSetFree: Int
		let framesPerOneDomesticCatSetFree: Int = 50
		///The speed with which people leave their houses. For example, if this property is 5, then
		///every 5 frames one person leave the house.
		let framesPerOnePersonLeavingHouse: Int
		
		let infectionRadius: CGFloat = 10	//The radius within which one agent may infect another.
		/// Incubation period, i.e. in this context, the number of times update() method is called before
		/// the disease status of an agent is "upgraded" from `infected` to `infectedShowingSymptoms`.
		let incubationPeriod: Int = 500
		/// Recovery period i.e. in this context, the number of times update() method is called before
		/// the disease status of an agent is "upgraded" from `infectedShowingSymptoms` to `removed`.
		let recoveryPeriod: Int = 750
		
		init(infectionProbabilities: InfectionProbability, numberOfDomesticCatsToBeSetFree: Int, framesPerOnePersonLeavingHouse: Int = 10) {
			self.infectionProbabilities = infectionProbabilities
			self.numberOfDomesticCatsToBeSetFree = max(0, numberOfDomesticCatsToBeSetFree)
			self.framesPerOnePersonLeavingHouse = max(1, framesPerOnePersonLeavingHouse)
		}
	}
}

struct InfectionProbability {
	let betweenPeople: InfectionTime
	let betweenCats: InfectionTime
	let betweenPersonAndCat: InfectionTime
	
	struct InfectionTime {
		let duringIncubation: CGFloat
		let afterIncubation: CGFloat
		static func duringIncubation(_ duringIncubation: CGFloat, after: CGFloat) -> InfectionTime {
			//Constrain probabilities between 1 and 0 inclusive using min and max functions.
			return InfectionTime(duringIncubation: min(max(0, duringIncubation), 1),
						afterIncubation: min(max(0, after), 1))
		}
	}
}
