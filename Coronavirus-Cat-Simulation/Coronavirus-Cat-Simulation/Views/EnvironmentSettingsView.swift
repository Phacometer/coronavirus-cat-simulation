//
//  EnvironmentSettingsView.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-10.
//  Copyright © 2020 vgao. All rights reserved.
//

import Cocoa

class EnvironmentSettingsView: NSStackView {

	@IBOutlet weak var householdNumberField: NSTextField!
	@IBOutlet weak var householdSizeField: NSTextField!
	@IBOutlet weak var numHouseholdsWithCatsField: NSTextField!
	@IBOutlet weak var wildCatsNumberField: NSTextField!
	@IBOutlet weak var domesticCatsToSetFreeField: NSTextField!
	
	func numberOfHouseholds() -> Int {
		return householdNumberField.integerValue
	}
	
	func householdSize() -> Int {
		return householdSizeField.integerValue
	}
	
	func numberOfHouseholdsWithCats() -> Int {
		return numHouseholdsWithCatsField.integerValue
	}
	
	func numberOfWildCats() -> Int {
		return wildCatsNumberField.integerValue
	}
	
	func numberOfDomesticCatsToSetFree() -> Int {
		return domesticCatsToSetFreeField.integerValue
	}
	
	func setNumberOfDomesticCatsToSetFree(_ cats: Int) {
		domesticCatsToSetFreeField.integerValue = cats
	}
    
}
