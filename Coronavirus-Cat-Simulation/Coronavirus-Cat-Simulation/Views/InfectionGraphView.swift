//
//  InfectionGraphView.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-08.
//  Copyright © 2020 vgao. All rights reserved.
//

import Cocoa

class InfectionGraphView: SimulationInformationView {
	
	private var frames: [Frame] = []
	private let spaceBetweenFrames: CGFloat = 5
	
	private let removedPartOfGraphFillColor: NSColor = .systemGray
	private let susceptiblePartOfGraphFillColor: NSColor = .systemBlue
	private let infectedPartOfGraphFillColor: NSColor = .systemYellow
	private let infectedAndSymptomaticPartOfGraphFillColor: NSColor = .systemRed

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

		drawGraph()
    }
	
	private func drawGraph() {
		//The graph is a layered and filled line graph that shows the number of agents in each disease state.
		drawRemovedPartOfGraph()
		drawSusceptiblePartOfGraph()
		drawInfectedAndSymptomaticPartOfGraph()
		drawInfectedPartOfGraph()
	}
	
	private func drawRemovedPartOfGraph() {
		let removedPartPath = NSBezierPath(rect: bounds)
		removedPartOfGraphFillColor.setFill()
		removedPartPath.fill()
	}
	
	private func drawSusceptiblePartOfGraph() {
		var pointsOnLine = [NSPoint]()
		for i in 0..<frames.count {
			let targetAgents = frames[i].numberOfSusceptibleAgents
				+ frames[i].numberOfInfectedAndSymptomaticAgents
				+ frames[i].numberOfInfectedAgents
			let point = pointOnLine(targetAgents: targetAgents, frameIndex: i)
			pointsOnLine.append(point)
		}
		drawFilledLineGraph(forLineWithPoints: pointsOnLine, color: susceptiblePartOfGraphFillColor)
		
		//There is a part of the graph before there is any frame data. The view assumes that in this part of
		//the graph, all agents are susceptible, and no agents are infected or removed. The code below draws
		//that part of the graph.
		drawPartOfGraphBeforeAnyFrameData(firstFramePoint: pointsOnLine.first)
	}
	
	private func drawPartOfGraphBeforeAnyFrameData(firstFramePoint: NSPoint?) {
		let firstPointX = firstFramePoint?.x ?? bounds.maxX
		if firstPointX > 0 {
			let susceptiblePartBeforeAnyFramePath = NSBezierPath(rect: NSRect(x: 0, y: 0,
																			  width: firstPointX,
																			  height: bounds.height))
			susceptiblePartOfGraphFillColor.setFill()
			susceptiblePartBeforeAnyFramePath.fill()
		}
	}
	
	private func drawInfectedAndSymptomaticPartOfGraph() {
		var pointsOnLine = [NSPoint]()
		for i in 0..<frames.count {
			let targetAgents = frames[i].numberOfInfectedAndSymptomaticAgents + frames[i].numberOfInfectedAgents
			let point = pointOnLine(targetAgents: targetAgents, frameIndex: i)
			pointsOnLine.append(point)
		}
		drawFilledLineGraph(forLineWithPoints: pointsOnLine, color: infectedAndSymptomaticPartOfGraphFillColor)
	}
	
	private func drawInfectedPartOfGraph() {
		var pointsOnLine = [NSPoint]()
		for i in 0..<frames.count {
			let targetAgents = frames[i].numberOfInfectedAgents
			let point = pointOnLine(targetAgents: targetAgents, frameIndex: i)
			pointsOnLine.append(point)
		}
		drawFilledLineGraph(forLineWithPoints: pointsOnLine, color: infectedPartOfGraphFillColor)
	}
	
	private func pointOnLine(targetAgents: Int, frameIndex: Int) -> NSPoint {
		assert(frameIndex < frames.count)
		let totalAgents = frames[frameIndex].totalAgents()
		return NSPoint(x: bounds.maxX - CGFloat(frames.count - frameIndex - 1) * spaceBetweenFrames,
					   y: CGFloat(targetAgents) / CGFloat(totalAgents) * bounds.height)
	}
	
	private func drawFilledLineGraph(forLineWithPoints points: [NSPoint], color: NSColor) {
		guard !points.isEmpty else {
			return
		}
		
		let path = NSBezierPath()
		path.move(to: NSPoint(x: points[0].x, y: bounds.minY))
		for point in points {
			path.line(to: point)
		}
		path.line(to: NSPoint(x: bounds.maxX, y: bounds.minY))
		path.close()
		
		color.setFill()
		path.fill()
	}
	
	func addFrame(_ frame: Frame) {
		frames.append(frame)
		setNeedsDisplay(bounds)
	}
	
	func clear() {
		frames = []
		setNeedsDisplay(bounds)
	}
    
}

extension InfectionGraphView {
	struct Frame {
		let numberOfSusceptibleAgents: Int
		let numberOfInfectedAgents: Int
		let numberOfInfectedAndSymptomaticAgents: Int
		let numberOfRemovedAgents: Int
		
		fileprivate func totalAgents() -> Int {
			return numberOfSusceptibleAgents
				+ numberOfInfectedAgents
				+ numberOfInfectedAndSymptomaticAgents
				+ numberOfRemovedAgents
		}
	}
}
