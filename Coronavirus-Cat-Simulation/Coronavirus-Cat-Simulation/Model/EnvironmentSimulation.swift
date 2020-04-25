//
//  EnvironmentSimulation.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-03.
//  Copyright © 2020 vgao. All rights reserved.
//

import Foundation

/// This class runs the simulation of an environment which includes simulating the movement of agents,
/// representing rules about infections, managing the disease state of each agent and the interaction
/// between agents. The simulation is composed of frames like a movie. You can ask the class to compute the next
/// frame. You can also ask it to give you a snapshot of the current frame, which contains the locations
/// of all the agents among other info.
class EnvironmentSimulation {
	private var environment: Environment
	private var _parameters: SimulationParameters
	private var simulationData: CurrentSimulationData = CurrentSimulationData()
	private let infectionStatusUpdater: InfectionStatusUpdater
	
	var parameters: SimulationParameters {
		get {
			return _parameters
		}
		set (parameters) {
			_parameters = parameters
			infectionStatusUpdater.probabilities = parameters.infectionProbabilities
		}
	}
	
	var framesComputed: Int  {
		return simulationData.framesPassed
	}
	
	init(startingSettings: Environment.StartingSettings, simulationParameters: SimulationParameters) {
		environment = Environment(settings: startingSettings)
		_parameters = simulationParameters
		infectionStatusUpdater = InfectionStatusUpdater(parameters: simulationParameters)
	}
	
	func computeNextFrame() {
		simulationData.framesPassed += 1
		
		//Set free one domestic cat and let one person leave house at specified intervals
		setFreeOneDomesticCatIfAppropriate()
		letOnePersonLeaveHouseIfAppropriate()
		
		moveAgents()
		
		//Update infection status
		infectionStatusUpdater.update(for: environment.agents)
	}
	
	func snapshotOfCurrentFrame() -> Snapshot {
		return Snapshot(fromEnvironment: environment)
	}
	
	// MARK: Helper methods
	
	private func setFreeOneDomesticCatIfAppropriate() {
		guard environment.domesticCats.count > 0 else {
			return
		}
		let timeToSetFreeCat = simulationData.framesPassed % parameters.framesPerOneDomesticCatSetFree == 0
		let stillCatsLeftToBeSetFree = simulationData.numberOfDomesticCatsAlreadySetFree < parameters.numberOfDomesticCatsToBeSetFree
		if timeToSetFreeCat && stillCatsLeftToBeSetFree {
			print(parameters.numberOfDomesticCatsToBeSetFree - simulationData.numberOfDomesticCatsAlreadySetFree)
			let randomDomesticCat = environment.domesticCats.shuffled()[0]
			randomDomesticCat.setFree()
			simulationData.numberOfDomesticCatsAlreadySetFree += 1
		}
	}
	
	private func letOnePersonLeaveHouseIfAppropriate() {
		if simulationData.framesPassed % parameters.framesPerOnePersonLeavingHouse == 0 {
			let personsAtHome = environment.persons.filter { !self.simulationData.personsOutOfHouse.contains($0) }
			if !personsAtHome.isEmpty {
				let randomPersonToLeaveHouse = personsAtHome[Int.random(in: 0..<personsAtHome.count)]
				assert(!simulationData.personsOutOfHouse.contains(randomPersonToLeaveHouse))
				simulationData.personsOutOfHouse.insert(randomPersonToLeaveHouse)
			}
		}
	}
	
	private func moveAgents() {
		for cat in environment.cats {
			cat.move()
		}
		for person in simulationData.personsOutOfHouse {
			person.move()
			if person.isAtHouse {	//If person has returned to house, then remove it from personsOutOfHouse.
				simulationData.personsOutOfHouse.remove(person)
			}
		}
	}
}

extension EnvironmentSimulation {
	struct Snapshot {
		let environmentDimensions: CGSize
		let persons: [(position: CGPoint, state: DiseaseState)]
		let cats: [(position: CGPoint, catType: Cat.CatType, state: DiseaseState)]
		let householdPositions: [CGPoint]
		
		fileprivate init(fromEnvironment environment: Environment) {
			self.environmentDimensions = environment.dimensions
			self.persons = environment.persons.map { ($0.position, $0.state) }
			self.cats = environment.cats.map { ($0.position, $0.type, $0.state) }
			self.householdPositions = environment.households.map { $0.positionOfHouse }
		}
	}
}

extension EnvironmentSimulation {
	fileprivate struct CurrentSimulationData {
		var numberOfDomesticCatsAlreadySetFree: Int = 0
		var framesPassed: Int = 0
		var personsOutOfHouse: Set<Person> = []
	}
}
