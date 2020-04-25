//
//  NSImage+.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-15.
//  Copyright © 2020 vgao. All rights reserved.
//

import Cocoa

extension NSImage {
	//Solution adopted from https://stackoverflow.com/a/39926740/2631081
    var jpegData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
		return bitmapImage.representation(using: .jpeg, properties: [:])
    }
    func jpegWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try jpegData?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
}
