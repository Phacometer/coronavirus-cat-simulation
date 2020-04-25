//
//  ViewController.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-01.
//  Copyright © 2020 vgao. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, SimulationBatchRunOperationDelegate {
	
	static let reportSimulationRunProgressNotification = Notification.Name("RunProgress")
	static let reportCurrentBatchInfoNotification = Notification.Name("CurrentBatchInfo")

	@IBOutlet weak var environmentView: SimulationEnvironmentView!
	@IBOutlet weak var graphView: InfectionGraphView!
	@IBOutlet weak var statisticsView: InfectionStatisticsView!
	@IBOutlet weak var settingsView: EnvironmentSettingsView!
	
	@IBOutlet weak var startButton: NSButton!
	@IBOutlet weak var pauseButton: NSButton!
	
	//This object controls how environmentView, graphView and statisticsView (collective known here as
	//simulation info views) are updated.
	private var simulationInfoViewsUpdater: SimulationInfoViewsUpdating!
	
	private let infectionProbabilities = InfectionProbability(betweenPeople: .duringIncubation(0.02, after: 0.05),
															  betweenCats: .duringIncubation(0.02, after: 0.05),
															  betweenPersonAndCat: .duringIncubation(0.01, after: 0.02))
	private var simulation: EnvironmentSimulation!
	private var simulationUpdateTimer: DisplayLink!
	private var isSimulationPlaying: Bool = false {
		didSet {
			startButton.isHidden = isSimulationPlaying
			pauseButton.isHidden = !isSimulationPlaying
			if isSimulationPlaying {
				simulationUpdateTimer.start()
			} else {
				simulationUpdateTimer.stop()
			}
		}
	}
	
	private var automaticRunOperation: SimulationBatchRunOperation!
	//Change the automatic running configuration by modifying the variable below
	private let automaticRunConfiguration = SimulationBatchRunOperation.Configuration.config(
		domesticCatsToSetFreeForEveryBatch: [0, 1, 5, 10], numTimesToRunPerBatch: 100)
	private lazy var automaticRunnerOperationQueue: OperationQueue = {
		return OperationQueue()
	}()
	private var screenshotsTakenDuringAutomaticRun: [String: NSImage] = [:]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		simulationInfoViewsUpdater = SimulationInfoViewsUpdating(environmentView: environmentView,
																 graphView: graphView,
																 statisticsView: statisticsView)

		makeNewSimulation()
		
		simulationUpdateTimer = DisplayLink(callback: {
			self.simulation.computeNextFrame()
			DispatchQueue.main.async {
				self.simulationInfoViewsUpdater.update(usingSimulationObject: self.simulation)
			}
		})
	}
	
	// MARK: SimulationBatchRunOperationDelegate
	
	func secondsToSleepBeforeReportingProgress() -> Double {
		return 0.1
	}
	
	func reportProgressOneSimulationDone(_ progress: CGFloat, simulationRunIndex: Int, currentBatchIndex: Int) {
		NotificationCenter.default.post(name: ViewController.reportSimulationRunProgressNotification, object: self, userInfo: ["progress": progress])
		
		//Screenshot window every 10 runs and add to screenshots array
		if simulationRunIndex % 10 == 0, let window = view.window {
			if let screenshot = CGWindowListCreateImage(.null, .optionIncludingWindow, CGWindowID(window.windowNumber), .bestResolution) {
				let image = NSImage(cgImage: screenshot, size: window.frame.size)
				let screenshotName = "\(currentBatchIndex).\(simulationRunIndex)"
				screenshotsTakenDuringAutomaticRun[screenshotName] = image
			} else {
				print("!!!!!!!")
				print("Screenshot taking failed, for simulation run index \(simulationRunIndex), batch index \(currentBatchIndex).")
			}
		}
		
		graphView.clear()
	}
	
	func reportCurrentSimulationFrame(_ snapshot: EnvironmentSimulation.Snapshot, framesComputed: Int) {
		simulationInfoViewsUpdater.update(usingSnapshot: snapshot, framesComputed: framesComputed)
	}
	
	func startingBatch(batchIndex: Int, numberOfCatsToSetFree: Int) {
		//Set field containing number of domestic cats to set free to match the batch set free number
		settingsView.setNumberOfDomesticCatsToSetFree(numberOfCatsToSetFree)
		
		NotificationCenter.default.post(name: ViewController.reportCurrentBatchInfoNotification, object: self, userInfo: ["index": batchIndex, "catsToSetFree": numberOfCatsToSetFree])
	}
	
	func simulationDone(result: SimulationBatchRunOperation.Result) {
		NSApp.stopModal()
		
		presentPanel(toSave: result)
	}
	
	// MARK: Target action
	
	@IBAction func startSimulation(_ sender: Any) {
		isSimulationPlaying = true
	}
	
	@IBAction func pauseSimulation(_ sender: Any) {
		isSimulationPlaying = false
	}
	
	@IBAction func newSimulation(_ sender: Any) {
		isSimulationPlaying = false
		makeNewSimulation()
	}
	
	@IBAction func runAutomatically(_ sender: Any) {
		let alertResponse = showAlertAskingUserWhetherToProceedWithAutomaticRun()
		if alertResponse == .alertSecondButtonReturn {
			runSimulationAutomatically()
			presentProgressControllerAndHandleResponse()
		}
	}
	
	// MARK: Methods dealing with automatic running
	
	private func showAlertAskingUserWhetherToProceedWithAutomaticRun() -> NSApplication.ModalResponse {
		let alert = NSAlert()
		alert.messageText = "Start running simulation automatically?"
		alert.informativeText = "The program will run four batches of simulation, with 100 runs per batch. Each batch will have the same variables entered except the number of domestic cat set free. You can change the configuration for the automatic run in code. The run may take a long time."
		alert.addButton(withTitle: "Cancel")
		alert.addButton(withTitle: "Run")
		alert.alertStyle = .informational
		return alert.runModal()
	}

	private func runSimulationAutomatically() {
		prepareForAutomaticRun()
		automaticRunOperation = SimulationBatchRunOperation(environmentSettings: extractStartingSettingsFromSettingsView(),
															infectionProbabilities: infectionProbabilities,
															configuration: automaticRunConfiguration)
		automaticRunOperation.delegate = self
		automaticRunnerOperationQueue.addOperation(automaticRunOperation)
	}
	
	private func prepareForAutomaticRun() {
		screenshotsTakenDuringAutomaticRun = [:]	//Clear any screenshots taken during previous run
		automaticRunnerOperationQueue.cancelAllOperations()	//Cancel previous operations before running. Only one can run at a time.
		graphView.clear()
	}
	
	private func presentProgressControllerAndHandleResponse() {
		let storyboard = NSStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateController(withIdentifier: "Simulation Run Progress Controller") as! NSWindowController
		if let window = controller.window {
			let response = NSApp.runModal(for: window)
			if response == .cancel {
				automaticRunnerOperationQueue.cancelAllOperations()
			}
			window.close()
		}
	}
	
	private func presentPanel(toSave result: SimulationBatchRunOperation.Result) {
		let panel = NSOpenPanel()
		panel.message = "Choose a folder in which to save the results."
		panel.canChooseFiles = false
		panel.canChooseDirectories = true
		panel.allowsMultipleSelection = false
		panel.canCreateDirectories = true
		panel.beginSheetModal(for: view.window!) { response in
			if response == .OK, let url = panel.url {
				self.save(result: result, to: url)
				self.saveScreenshots(to: url)
			}
		}
	}
	
	private func save(result: SimulationBatchRunOperation.Result, to url: URL) {
		let csvString = RunResultToCSVConverter.csvString(from: result)
		let fileURL = url.appendingPathComponent("results.csv")
		do {
			try csvString.write(to: fileURL, atomically: false, encoding: .utf8)
		} catch {
			print("!!!!!!!!!")
			print("Write result to results.csv failed!")
		}
	}
	
	private func saveScreenshots(to url: URL) {
		for (name, screenshot) in screenshotsTakenDuringAutomaticRun {
			let fileURL = url.appendingPathComponent("\(name).jpeg")
			let result = screenshot.jpegWrite(to: fileURL)
			if !result {
				print("!!!!!!")
				print("Writing to \(name).jpeg file failed!")
			}
		}
	}
	
	// MARK: Helper methods
	
	private func makeNewSimulation() {
		let settings = extractStartingSettingsFromSettingsView()
		let parameters = EnvironmentSimulation.SimulationParameters(infectionProbabilities: infectionProbabilities,
																	numberOfDomesticCatsToBeSetFree: settingsView.numberOfDomesticCatsToSetFree())
		simulation = EnvironmentSimulation(startingSettings: settings, simulationParameters: parameters)
		
		simulationInfoViewsUpdater.update(usingSimulationObject: simulation)
	}
	
	private func extractStartingSettingsFromSettingsView() -> Environment.StartingSettings {
		return Environment.StartingSettings(spaceSideLength: 150,
											numberOfHouseholds: settingsView.numberOfHouseholds(),
											householdSize: settingsView.householdSize(),
											percentageOfHouseholdsWithCats: CGFloat(settingsView.numberOfHouseholdsWithCats())
												/ CGFloat(settingsView.numberOfHouseholds()),
											numberOfWildCats: settingsView.numberOfWildCats())
	}
	
}

extension ViewController {
	/// This class manages the updating of the views containing current simulation information in ViewController
	private class SimulationInfoViewsUpdating: SimulationEnvironmentViewDataSource {
		let environmentView: SimulationEnvironmentView
		let graphView: InfectionGraphView
		let statisticsView: InfectionStatisticsView
		
		private var currentSnapshot: EnvironmentSimulation.Snapshot!
		
		private let framesPerUpdatingGraphViewOnce: Int = 30
		
		init(environmentView: SimulationEnvironmentView, graphView: InfectionGraphView, statisticsView: InfectionStatisticsView) {
			self.environmentView = environmentView
			self.graphView = graphView
			self.statisticsView = statisticsView
			
			environmentView.dataSource = self
		}
		
		func update(usingSimulationObject simulation: EnvironmentSimulation) {
			currentSnapshot = simulation.snapshotOfCurrentFrame()
			
			environmentView.setNeedsDisplay(environmentView.bounds)
			updateStatisticsView(withFramesComputed: simulation.framesComputed)
			updateGraphView(framesComputed: simulation.framesComputed)
		}
		
		func update(usingSnapshot snapshot: EnvironmentSimulation.Snapshot, framesComputed: Int) {
			currentSnapshot = snapshot
			
			environmentView.setNeedsDisplay(environmentView.bounds)
			updateStatisticsView(withFramesComputed: framesComputed)
			updateGraphView(framesComputed: framesComputed)
		}
		
		// MARK: SimulationEnvironmentViewDataSource
		
		func environmentSize() -> NSSize {
			return currentSnapshot.environmentDimensions
		}
		
		func householdPositions() -> [NSPoint] {
			return currentSnapshot.householdPositions
		}
		
		func agents() -> [SimulationEnvironmentView.Agent] {
			var agents = [SimulationEnvironmentView.Agent]()
			for cat in currentSnapshot.cats {
				agents.append(SimulationEnvironmentView.Agent(position: cat.position,
															  type: cat.catType == .domestic || cat.catType == .domesticSetFree ? .domesticCat : .wildCat,
															  state: cat.state))
			}
			for person in currentSnapshot.persons {
				agents.append(SimulationEnvironmentView.Agent(position: person.position, type: .person, state: person.state))
			}
			return agents
		}
		
		// MARK: Private methods
		
		private func updateStatisticsView(withFramesComputed framesComputed: Int) {
			if framesComputed == 0 {
				statisticsView.clearFrameCount()
			}
			
			let numbers = tallySimulationSnapshotPeopleNumbers()
			statisticsView.setSusceptibleCount(numbers.susceptible)
			statisticsView.setInfectedCount(numbers.infected)
			statisticsView.setInfectedSymptomaticCount(numbers.infectedSymptomatic)
			statisticsView.setRemovedCount(numbers.removed)

			statisticsView.setFrameCount(framesComputed)
		}
		
		private func updateGraphView(framesComputed: Int) {
			if framesComputed % framesPerUpdatingGraphViewOnce == 1 {
				addFrameToGraphView()
			} else if framesComputed == 0 {
				graphView.clear()
			}
		}
		
		private func addFrameToGraphView() {
			//Get frame from simulation snapshot numbers and add it to graphView
			let numbers = tallySimulationSnapshotPeopleNumbers()
			let frame = InfectionGraphView.Frame(numberOfSusceptibleAgents: numbers.susceptible,
												 numberOfInfectedAgents: numbers.infected,
												 numberOfInfectedAndSymptomaticAgents: numbers.infectedSymptomatic,
												 numberOfRemovedAgents: numbers.removed)
			graphView.addFrame(frame)
		}
		
		private func tallySimulationSnapshotPeopleNumbers() -> (susceptible: Int, infected: Int,
			infectedSymptomatic: Int, removed: Int) {
			var susceptibleCount = 0
			var infectedCount = 0
			var infectedSymptomaticCount = 0
			var removedCount = 0
			for person in currentSnapshot.persons {
				switch person.state {
				case .susceptible:
					susceptibleCount += 1
				case .infected:
					infectedCount += 1
				case .infectedShowingSymptoms:
					infectedSymptomaticCount += 1
				case .removed:
					removedCount += 1
				}
			}
			return (susceptibleCount, infectedCount, infectedSymptomaticCount, removedCount)
		}
	}
}

