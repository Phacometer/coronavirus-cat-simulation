//
//  SimulationInformationView.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-12.
//  Copyright © 2020 vgao. All rights reserved.
//

import Cocoa

class SimulationInformationView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

		drawBackground()
    }
	
	private func drawBackground() {
		let background = NSBezierPath(rect: bounds)
		NSColor.textBackgroundColor.setFill()
		NSColor.tertiaryLabelColor.setStroke()
		background.fill()
		background.stroke()
	}
    
}
