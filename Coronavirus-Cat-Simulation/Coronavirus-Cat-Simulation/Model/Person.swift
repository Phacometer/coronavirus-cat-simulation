//
//  Person.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-02.
//  Copyright © 2020 vgao. All rights reserved.
//

import Foundation

class Person: Agent, Hashable {
	private var _position: CGPoint
	private var walk = WalkingData()
	private var walkingAlgorithm = AgentMovementAlgorithm()
	
	private var _state: DiseaseState = .susceptible
	
	private var _household: Household
	private var isOutOfHouse: Bool = false
	
	private weak var _delegate: AgentDelegate?
	
	var position: CGPoint {
		get {
			return _position
		}
	}
	
	var state: DiseaseState {
		get {
			return _state
		}
		set(state) {
			_state = state
		}
	}
	
	var delegate: AgentDelegate? {
		get {
			return _delegate
		}
		set (delegate) {
			_delegate = delegate
		}
	}
	
	var household: Household {
		get {
			return _household
		}
	}
	
	/// The "duration" here means number of times the move() method is called. E.g. if the duration is 10,
	/// then the average walk will take about 10 calls of move() to complete.
	var averageWalkDuration: Int {
		get {
			return walk.averageWalkDuration
		}
		set (length) {
			walk.averageWalkDuration = abs(length)
		}
	}
	
	var isAtHouse: Bool {
		return !isOutOfHouse
	}
	
	init(household: Household) {
		_household = household
		_position = household.positionOfHouse
		walkingAlgorithm.maximumTurningAngle = CGFloat.pi / 2
	}
	
	func move() {
		if !isOutOfHouse {
			beginWalking()
		}
		//This is how a person moves: a person starts at the house, walks out for a while, then returns to house.
		if !walk.isRetracingStepsBackToHouse {
			walkAwayFromHouse()
			if isTimeToGoBackToHouse() {
				walk.isRetracingStepsBackToHouse = true
			}
		} else {
			retraceLastStepBackToHouse()
			if isBackAtHouse() {
				endWalk()
			}
		}
	}
	
	static func == (lhs: Person, rhs: Person) -> Bool {
		return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(ObjectIdentifier(self))
	}
	
	// MARK: Helper methods
	
	private func beginWalking() {
		isOutOfHouse = true
	}
	
	private func walkAwayFromHouse() {
		let previousPosition = _position
		
		//Calculate new position
		_position = walkingAlgorithm.calculateNewPosition(from: previousPosition)
		if let delegate = delegate, delegate.isPositionOutOfBounds(_position) {
			_position = delegate.withinBoundsPosition(for: _position)
		}
		
		//Update walking data
		walk.totalDurationAlreadyWalked += 1
		walk.walkingHistory.append(previousPosition)
	}
	
	private func isTimeToGoBackToHouse() -> Bool {
		//Turn around and walk back to house if past half of averageWalkLength
		return walk.totalDurationAlreadyWalked >= walk.averageWalkDuration / 2
	}
	
	private func retraceLastStepBackToHouse() {
		assert(!walk.walkingHistory.isEmpty)
		_position = walk.walkingHistory.removeLast()
	}
	
	private func isBackAtHouse() -> Bool {
		return walk.walkingHistory.isEmpty
	}
	
	private func endWalk() {
		isOutOfHouse = false
		walk.resetWalkEnded()
		walkingAlgorithm.reset()
	}
}

extension Person {
	private struct WalkingData {
		//The two properties below do not change between walks.
		var averageWalkDuration: Int = 100
		
		//These properties do change between walks.
		var totalDurationAlreadyWalked: Int = 0
		var walkingHistory: [CGPoint] = []	//Stores all the previous points that the person walked on
		var isRetracingStepsBackToHouse: Bool = false
		
		mutating func resetWalkEnded() {
			totalDurationAlreadyWalked = 0
			walkingHistory = []
			isRetracingStepsBackToHouse = false
		}
	}
}
