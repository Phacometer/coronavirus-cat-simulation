//
//  Environment.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-03.
//  Copyright © 2020 vgao. All rights reserved.
//

import Foundation

/// This class encapsulates information about an environment such as the agents inside it and its dimensions.
/// It does not run the simulation, which is the job of EnvironmentSimulation class.
class Environment: AgentDelegate {
	private var spaceSideLength: CGFloat
	private var _cats: [Cat] = []
	private var _persons: [Person] = []
	private var _households: [Household] = []
	
	var dimensions: CGSize {
		return CGSize(width: spaceSideLength, height: spaceSideLength)
	}
	
	var agents: [Agent] {
		return _cats + _persons
	}
	
	var cats: [Cat] {
		return _cats
	}
	
	var domesticCats: [Cat] {
		return _cats.filter { $0.type == .domestic }
	}
	
	var wildCats: [Cat] {
		return _cats.filter { $0.type == .wild || $0.type == .domesticSetFree }
	}
	
	var persons: [Person] {
		return _persons
	}
	
	var households: [Household] {
		return _households
	}
	
	init(settings: StartingSettings) {
		//Initialize environment
		spaceSideLength = settings.environmentSpaceSideLength
		initializeHouseholds(numberOfHouseholds: settings.numberOfHouseholds)
		initializePersons(numberPerHousehold: settings.householdSize,
						  numberToSetToInfected: settings.numberOfInfectedPersons)
		initializeDomesticCats(forPercentageOfHouseholds: settings.percentageOfHouseholdsWithCats)
		initializeWildCats(number: settings.numberOfWildCats)
	}
	
	private func initializeHouseholds(numberOfHouseholds: Int) {
		assert(households.isEmpty, "Households is not empty! Should only be called when households is empty.")
		
		//Distribute households evenly across the environment, in a grid pattern. The space between
		//households is same as space between the household and the border.
		let columns = Int(sqrt(Double(numberOfHouseholds)).rounded())
		let rows = Int((Double(numberOfHouseholds) / Double(columns)).rounded(.up))
		let spaceBetweenColumns = spaceSideLength / CGFloat(columns + 1)
		let spaceBetweenRows = spaceSideLength / CGFloat(rows + 1)
		
		for i in 0..<numberOfHouseholds {
			let rowIndex = i / columns + 1
			let columnIndex = i % columns + 1
			let position = CGPoint(x: CGFloat(rowIndex) * spaceBetweenRows,
								   y: CGFloat(columnIndex) * spaceBetweenColumns)
			_households.append(Household(positionOfHouse: position))
		}
	}
	
	private func initializePersons(numberPerHousehold: Int, numberToSetToInfected: Int) {
		assert(_persons.isEmpty, "Persons is not empty! Should only be called when persons is empty.")
		
		for household in households {
			for _ in 0..<numberPerHousehold {
				let person = Person(household: household)
				person.delegate = self
				_persons.append(person)
			}
		}
		
		//Set a random sample of persons to infected state in order to kickstart infection process.
		for person in persons.shuffled()[0..<numberToSetToInfected] {
			person.state = .infected
		}
	}
	
	private func initializeDomesticCats(forPercentageOfHouseholds percentage: CGFloat) {
		let numberOfHouseholdsWithCats = Int((percentage * CGFloat(households.count)).rounded())
		let chosenHouseholdsWithCats = households.shuffled()[0..<numberOfHouseholdsWithCats]
		for household in chosenHouseholdsWithCats {
			let cat = Cat.domesticCat(ofHousehold: household)
			cat.delegate = self
			_cats.append(cat)
		}
	}
	
	private func initializeWildCats(number: Int) {
		for _ in 0..<number {
			let randomPosition = CGPoint(x: CGFloat.random(in: 0...spaceSideLength),
										 y: CGFloat.random(in: 0...spaceSideLength))
			addNewCat(Cat.wildCat(atPosition: randomPosition))
		}
	}
	
	private func addNewCat(_ cat: Cat) {
		cat.delegate = self
		_cats.append(cat)
	}
	
	// MARK: AgentDelegate
	
	func isPositionOutOfBounds(_ position: CGPoint) -> Bool {
		return position.x < 0 || position.x > spaceSideLength || position.y < 0 || position.y > spaceSideLength
	}
	
	func withinBoundsPosition(for position: CGPoint) -> CGPoint {
		var newPosition = position
		newPosition.x = max(0, newPosition.x)
		newPosition.x = min(spaceSideLength, newPosition.x)
		newPosition.y = max(0, newPosition.y)
		newPosition.y = min(spaceSideLength, newPosition.y)
		return newPosition
	}
}
