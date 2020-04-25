//
//  Cat.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-02.
//  Copyright © 2020 vgao. All rights reserved.
//

import Foundation

class Cat: Agent {
	enum CatType {
		case domestic
		case domesticSetFree
		case wild
	}
	
	private var _position: CGPoint
	private var _state: DiseaseState = .susceptible
	private var _type: CatType
	private var _household: Household?
	private var _movementAlgorithm = AgentMovementAlgorithm()
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
		set (state) {
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
	
	var household: Household? {
		get {
			return _household
		}
	}
	
	var type: CatType {
		return _type
	}
	
	private init(household: Household?, position: CGPoint) {
		_household = household
		_position = household?.positionOfHouse ?? position
		_type = household == nil ? .wild : .domestic
		_movementAlgorithm.numberOfTimesToCalculateBeforeSwitchingDirection = 3
		_movementAlgorithm.distanceOfEachMovement = 0.8
	}
	
	class func domesticCat(ofHousehold household: Household) -> Cat {
		return Cat(household: household, position: household.positionOfHouse)
	}
	
	class func wildCat(atPosition position: CGPoint) -> Cat {
		return Cat(household: nil, position: position)
	}
	
	func move() {
		guard type == .wild || type == .domesticSetFree else {	//Only wild cats can move
			return
		}
		
		_position = _movementAlgorithm.calculateNewPosition(from: _position)
		if let delegate = delegate, delegate.isPositionOutOfBounds(_position) {
			_position = delegate.withinBoundsPosition(for: _position)
		}
	}
	
	func setFree() {
		_type = .domesticSetFree
		_household = nil
	}
	
	static func == (lhs: Cat, rhs: Cat) -> Bool {
		return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(ObjectIdentifier(self))
	}
}
