//
//  NSBezierPath+.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-11.
//  Copyright © 2020 vgao. All rights reserved.
//

import Cocoa

extension NSBezierPath {
	convenience init(triangleIn rect: NSRect) {
		self.init()
		move(to: NSPoint(x: rect.midX, y: rect.minY))
		line(to: NSPoint(x: rect.maxX, y: rect.maxY))
		line(to: NSPoint(x: rect.minX, y: rect.maxY))
		close()
	}
}
