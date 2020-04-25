//
//  InfectionStatisticsView.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-12.
//  Copyright © 2020 vgao. All rights reserved.
//

import Cocoa

class InfectionStatisticsView: NSStackView {

	@IBOutlet weak var susceptibleCountLabel: NSTextField!
	@IBOutlet weak var infectedCountLabel: NSTextField!
	@IBOutlet weak var infectedSymptomaticCountLabel: NSTextField!
	@IBOutlet weak var removedCountLabel: NSTextField!
	@IBOutlet weak var frameCountLabel: NSTextField!
	
	private var frameCount: Int = 0
	private var maxFrameCount: Int = 3214
	private var isFrozen: Bool {
		return frameCount >= maxFrameCount
	}
	
	func setSusceptibleCount(_ count: Int) {
		if !isFrozen {
			susceptibleCountLabel.stringValue = "Susceptible count: \(count)"
		}
	}
	
	func setInfectedCount(_ count: Int) {
		if !isFrozen {
			infectedCountLabel.stringValue = "Infected count: \(count)"
		}
	}
	
	func setInfectedSymptomaticCount(_ count: Int) {
		if !isFrozen {
			infectedSymptomaticCountLabel.stringValue = "Infected and symptomatic count: \(count)"
		}
	}
	
	func setRemovedCount(_ count: Int) {
		if !isFrozen {
			removedCountLabel.stringValue = "Removed count: \(count)"
		}
	}
	
	func setFrameCount(_ frames: Int) {
		frameCount = frames
		if isFrozen {
			frameCountLabel.stringValue = "Frame count: \(maxFrameCount) (reached max)"
		} else {
			frameCountLabel.stringValue = "Frame count: \(frames)"
		}
	}
	
	func clearFrameCount() {
		frameCount = 0
		frameCountLabel.stringValue = "Frame count: 0"
	}
	
	func setMaxFrameCount(_ count: Int) {
		frameCount = count
	}
    
}
