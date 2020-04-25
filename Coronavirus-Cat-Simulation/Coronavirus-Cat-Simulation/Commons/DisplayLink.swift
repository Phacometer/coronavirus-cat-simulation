//
//  DisplayLink.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-11.
//  Copyright © 2020 vgao. All rights reserved.
//

import Cocoa

/// A Swifty wrapper for CVDisplayLink on macOS.
class DisplayLink {
	private var link: CVDisplayLink!
	
	init(callback: @escaping () -> ()) {
		CVDisplayLinkCreateWithActiveCGDisplays(&link)
		CVDisplayLinkSetOutputHandler(link) { _, _, _, _, _ -> CVReturn in
			callback()
			return kCVReturnSuccess
		}
	}
	
	deinit {
		CVDisplayLinkStop(link)
	}
	
	func start() {
		CVDisplayLinkStart(link)
	}
	
	func stop() {
		CVDisplayLinkStop(link)
	}
}
