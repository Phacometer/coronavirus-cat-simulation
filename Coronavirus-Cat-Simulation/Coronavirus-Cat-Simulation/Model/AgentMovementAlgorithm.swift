//
//  AgentMovementAlgorithm.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-02.
//  Copyright © 2020 vgao. All rights reserved.
//

import Foundation

/// Represents the shared algorithm with which agents move.
class AgentMovementAlgorithm {
	private var _distanceOfEachMovement: CGFloat = 1
	private var _maximumTurningAngle: CGFloat = CGFloat.pi	//Defaults to 180 degrees in either direction, i.e. can turn
															//to whichever direction possible
	private var _numTimesBeforeSwitchingDirection: Int = 5
	
	private var _directionOfMovement: CGFloat?
	private var _timesAlreadyCalculatedInSameDirection: Int = 0
	
	var distanceOfEachMovement: CGFloat {
		get {
			return _distanceOfEachMovement
		}
		set (distance) {
			_distanceOfEachMovement = abs(distance)
		}
	}
	
	/// The maximum angle in radians to left or right that the agent is allowed to turn. This property defaults to 180
	/// degrees (but in radians), i.e. the agent can turn whichever way it wants, even backwards. The maximum value
	/// allowed is 180 degrees (in radians).
	var maximumTurningAngle: CGFloat {
		get {
			return _maximumTurningAngle
		}
		set (angle) {
			if abs(angle) > CGFloat.pi {
				_maximumTurningAngle = CGFloat.pi
			} else {
				_maximumTurningAngle = abs(angle)
			}
		}
	}
	
	var numberOfTimesToCalculateBeforeSwitchingDirection: Int {
		get {
			return _numTimesBeforeSwitchingDirection
		}
		set (times) {
			_numTimesBeforeSwitchingDirection = abs(times)
		}
	}
	
	func calculateNewPosition(from position: CGPoint) -> CGPoint {
		if _directionOfMovement == nil {
			_directionOfMovement = calculateRandomDirection()
		}
		
		var newPosition = position
		newPosition.x += cos(_directionOfMovement!) * distanceOfEachMovement
		newPosition.y += sin(_directionOfMovement!) * distanceOfEachMovement
		
		_timesAlreadyCalculatedInSameDirection += 1
		changeDirectionIfNeeded()
		
		return newPosition
	}
	
	func reset() {
		_directionOfMovement = nil
		_timesAlreadyCalculatedInSameDirection = 0
	}
	
	private func changeDirectionIfNeeded() {
		if _timesAlreadyCalculatedInSameDirection >= numberOfTimesToCalculateBeforeSwitchingDirection {
			_directionOfMovement = calculateNewDirectionFromCurrentDirection()
			_timesAlreadyCalculatedInSameDirection = 0
		}
	}
	
	private func calculateRandomDirection() -> CGFloat {
		return CGFloat.random(in: 0..<(2*CGFloat.pi))
	}
	
	private func calculateNewDirectionFromCurrentDirection() -> CGFloat {
		guard let direction = _directionOfMovement else {
			return calculateRandomDirection()
		}
		//Calculates a new direction from the current movement direction. There is a limit to how much
		//a person can turn from the current direction. The maximum turning angle is 90 degrees left or right, as
		//represented by the lower and upper bounds below. The limit is here to capture as best as possible
		//how a real-life person walks, i.e. he/she is unlikely to turn more than 90 degrees in either direction while
		//walking.
		let directionLowerBound = direction - maximumTurningAngle
		let directionUpperBound = direction + maximumTurningAngle
		return CGFloat.random(in: directionLowerBound...directionUpperBound)
	}
}
