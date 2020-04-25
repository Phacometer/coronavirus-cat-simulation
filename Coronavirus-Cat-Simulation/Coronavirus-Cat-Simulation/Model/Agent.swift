//
//  Agent.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-02.
//  Copyright © 2020 vgao. All rights reserved.
//

import Foundation

/// An "agent" is a factor in the coronavirus simulation that can move about in an
/// environment and transmit disease.
protocol Agent: class {
	var position: CGPoint { get }
	var state: DiseaseState { get set }
	var delegate: AgentDelegate? { get set }
	
	func move()
}

protocol AgentDelegate: class {
	func isPositionOutOfBounds(_ position: CGPoint) -> Bool
	func withinBoundsPosition(for position: CGPoint) -> CGPoint
}
