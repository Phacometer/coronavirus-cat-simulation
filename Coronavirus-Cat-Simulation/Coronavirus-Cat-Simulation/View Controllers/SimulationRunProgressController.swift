//
//  SimulationRunProgressController.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-14.
//  Copyright © 2020 vgao. All rights reserved.
//

import Cocoa

class SimulationRunProgressController: NSViewController {

	@IBOutlet weak var statusLabel: NSTextField!
	@IBOutlet weak var percentageLabel: NSTextField!
	@IBOutlet weak var progressIndicator: NSProgressIndicator!
	
	override func viewDidLoad() {
        super.viewDidLoad()
        
		NotificationCenter.default.addObserver(self, selector: #selector(updateProgress(notification:)), name: ViewController.reportSimulationRunProgressNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(updateStatusLabelWithCurrentBatchInfo(notification:)), name: ViewController.reportCurrentBatchInfoNotification, object: nil)
    }
	
	@objc func updateProgress(notification: Notification) {
		if let progress = notification.userInfo?["progress"] as? CGFloat {
			progressIndicator.doubleValue = Double(progress * 100)
			let roundedProgress = ((progress*1000).rounded()) / 10
			percentageLabel.stringValue = "\(roundedProgress)%"
		}
	}
	
	@objc func updateStatusLabelWithCurrentBatchInfo(notification: Notification) {
		let batchNumber = (notification.userInfo!["index"] as! Int) + 1
		let cats = (notification.userInfo!["catsToSetFree"] as! Int)
		statusLabel.stringValue = "Running simulation batch #\(batchNumber), \(cats) cats to set free..."
	}
    
	@IBAction func cancel(_ sender: Any) {
		NSApp.stopModal(withCode: .cancel)
	}
	
}
