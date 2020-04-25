//
//  SimulationEnvironmentView.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-08.
//  Copyright © 2020 vgao. All rights reserved.
//

import Cocoa

protocol SimulationEnvironmentViewDataSource: class {
	func environmentSize() -> NSSize
	func householdPositions() -> [NSPoint]
	func agents() -> [SimulationEnvironmentView.Agent]
}

class SimulationEnvironmentView: SimulationInformationView {
	
	weak var dataSource: SimulationEnvironmentViewDataSource?
		
	private let susceptibleAgentsColor: NSColor = .systemBlue
	private let duringIncubationInfectedAgentsColor: NSColor = .systemYellow
	private let afterIncubationInfectedAgentsColor: NSColor = .systemRed
	private let removedAgentsColor: NSColor = .systemGray
		
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
		
		drawHouseholds()
		drawAgents()
	}
	
	private func drawHouseholds() {
		guard let dataSource = dataSource else {
			return
		}
		
		let environmentSize = dataSource.environmentSize()
		
		let householdPositions = dataSource.householdPositions()
		let householdRectangleSideLength: CGFloat = 15
		for household in householdPositions {
			let positionRelativeToView = convertEnvironmentPointToViewPoint(household, in: environmentSize)
			let path = NSBezierPath(rect: NSRect(x: positionRelativeToView.x - householdRectangleSideLength / 2,
												 y: positionRelativeToView.y - householdRectangleSideLength / 2,
												 width: householdRectangleSideLength,
												 height: householdRectangleSideLength))
			NSColor.gray.withAlphaComponent(0.5).setStroke()
			path.stroke()
		}
	}
	
	private func drawAgents() {
		guard let dataSource = dataSource else {
			return
		}
		
		let environmentSize = dataSource.environmentSize()
		let agents = dataSource.agents()
		for agent in agents {
			drawAgent(agent, environmentSize: environmentSize)
		}
	}
	
	private func drawAgent(_ agent: Agent, environmentSize: NSSize) {
		let positionRelativeToView = convertEnvironmentPointToViewPoint(agent.position, in: environmentSize)
		let personSymbolWidthHeight: CGFloat = 8
		let wildCatSymbolWidthHeight: CGFloat = 4
		let domesticCatSymbolWidthHeight: CGFloat = 6
		
		//Set agent symbol fill color
		switch agent.state {
		case .susceptible:
			susceptibleAgentsColor.setFill()
		case .infected:
			duringIncubationInfectedAgentsColor.setFill()
		case .infectedShowingSymptoms:
			afterIncubationInfectedAgentsColor.setFill()
		case .removed:
			removedAgentsColor.setFill()
		}
		
		//Draw agent symbol: circle if it is a cat, square if it is a person.
		switch agent.type {
		case .wildCat:
			let path = NSBezierPath(ovalIn: NSRect(x: positionRelativeToView.x - wildCatSymbolWidthHeight / 2,
												   y: positionRelativeToView.y - wildCatSymbolWidthHeight / 2,
												   width: wildCatSymbolWidthHeight, height: wildCatSymbolWidthHeight))
			path.fill()
		case .domesticCat:
			let path = NSBezierPath(triangleIn: NSRect(x: positionRelativeToView.x - domesticCatSymbolWidthHeight / 2,
													   y: positionRelativeToView.y - domesticCatSymbolWidthHeight / 2,
													   width: domesticCatSymbolWidthHeight,
													   height: domesticCatSymbolWidthHeight))
			path.fill()
		case .person:
			let path = NSBezierPath(rect: NSRect(x: positionRelativeToView.x - personSymbolWidthHeight / 2,
												   y: positionRelativeToView.y - personSymbolWidthHeight / 2,
												   width: personSymbolWidthHeight, height: personSymbolWidthHeight))
			path.fill()
		}
	}
	
	private func convertEnvironmentPointToViewPoint(_ point: NSPoint, in environmentSize: NSSize) -> NSPoint {
		return NSPoint(x: point.x / environmentSize.width * bounds.width,
					   y: point.y / environmentSize.height * bounds.height)
	}
    
}

extension SimulationEnvironmentView {
	struct Agent {
		let position: NSPoint
		let type: AgentType
		let state: DiseaseState
	}
	
	enum AgentType {
		case domesticCat
		case wildCat
		case person
	}
}
