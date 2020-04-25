//
//  InfectionStatusUpdater.swift
//  Coronavirus-Cat-Simulation
//
//  Created by Victor Gao on 2020-04-15.
//  Copyright © 2020 vgao. All rights reserved.
//

import Foundation

/// This class is used by EnvironmentSimulation to update the infection status of the simulation's agents.
/// It contains the infection rules and exceptions.
class InfectionStatusUpdater {
	///See SimulationParameters in Simulation Variables.swift.
	var infectionRadius: CGFloat
	/// See SimulationParameters in Simulation Variables.swift.
	var incubationPeriod: Int
	/// See SimulationParameters in Simulation Variables.swift.
	var recoveryPeriod: Int
	var probabilities: InfectionProbability
	
	/// This property stores the amount of time (in number of times the update() method is called) that
	/// each agent has been infected.
	private var agentsInfectionElapsedTime: [AgentHashableDecorator: Int] = [:]
	
	init(parameters: EnvironmentSimulation.SimulationParameters) {
		self.infectionRadius = parameters.infectionRadius
		self.incubationPeriod = parameters.incubationPeriod
		self.recoveryPeriod = parameters.recoveryPeriod
		self.probabilities = parameters.infectionProbabilities
	}
	
	func update(for agents: [Agent]) {
		//Infected agents may infect non-infected agents.
		updateInfectionStatusForNonInfectedAgents(with: agents)
		//Already infected agents who are not showing symptoms may "upgrade" to showing symptoms,
		//and infected agents who are showing symptoms may "upgrade" to recovered/removed,
		//i.e. developed antibodies and not able to infect anyone anymore.
		upgradeStatusForAlreadyInfectedAgents()
	}
	
	// MARK: Helper methods
	
	private func updateInfectionStatusForNonInfectedAgents(with agents: [Agent]) {
		//Infected agents will infect non-infected agents if they are close enough.
		let infectedAgents = agents.filter { $0.state == .infected || $0.state == .infectedShowingSymptoms }
		let notInfectedAgents = agents.filter { $0.state == .susceptible }
		for infected in infectedAgents {
			addAgentToInfectedTimeDictionaryIfHaveNotAlready(infected)
			for notInfected in notInfectedAgents {
				if should(infected, infect: notInfected) {
					notInfected.state = .infected
					addAgentToInfectedTimeDictionaryIfHaveNotAlready(notInfected)
				}
			}
		}
	}
	
	private func addAgentToInfectedTimeDictionaryIfHaveNotAlready(_ agent: Agent) {
		let decorator = AgentHashableDecorator(agent: agent)
		if agentsInfectionElapsedTime[decorator] == nil {
			agentsInfectionElapsedTime[decorator] = 0
		}
	}
	
	private func upgradeStatusForAlreadyInfectedAgents() {
		//"Upgrading" means: if disease state is "infected" and incubated long enough, then upgrade to
		//"infectedShowingSymptoms"; if disease state is "infectedShowingSymptoms" and recovered long enough, then
		//upgrade to "removed" (i.e. not able to infect anyone anymore).
		for (agentHashable, time) in agentsInfectionElapsedTime {
			if agentHashable.agent.state == .infected && time >= incubationPeriod {
				agentHashable.agent.state = .infectedShowingSymptoms
			}
			if agentHashable.agent.state == .infectedShowingSymptoms && time >= incubationPeriod + recoveryPeriod {
				agentHashable.agent.state = .removed
				agentsInfectionElapsedTime.removeValue(forKey: agentHashable)
			}
			agentsInfectionElapsedTime[agentHashable]? += 1
		}
	}
	
	private func should(_ agent: Agent, infect anotherAgent: Agent) -> Bool {
		//This method contains the algorithm for deciding whether an agent should infect another agent.
		if agentsSatisfyInfectionRuleExceptions(agent, anotherAgent) {
			return false	//There are exceptions to infection rules in which some agents cannot infect others
		} else {
			let withinInfectionRadius = distance(between: agent, and: anotherAgent) <= infectionRadius
			let withinInfectionProbability = CGFloat.random(in: 0..<1) < probabilityOfInfection(between: agent,
																								and: anotherAgent)
			return withinInfectionRadius && withinInfectionProbability
		}
	}
	
	private func agentsSatisfyInfectionRuleExceptions(_ agent: Agent, _ anotherAgent: Agent) -> Bool {
		return isOneAgentPersonAtHomeAndTheOtherPersonOutside(agent, anotherAgent)
			|| isOneAgentNonDomesticCatAndTheOtherPersonAtHome(agent, anotherAgent)
			|| isOneAgentDomesticCatAndTheOtherPersonOutside(agent, anotherAgent)
			|| isOneAgentDomesticCatAndOtherNonDomestic(agent, anotherAgent)
			|| areBothAgentsAtHomeAndInDifferentHouses(agent, anotherAgent)
	}
	
	private func isOneAgentNonDomesticCatAndTheOtherPersonAtHome(_ agent: Agent, _ anotherAgent: Agent) -> Bool {
		let cat = agent as? Cat ?? anotherAgent as? Cat
		let person = agent as? Person ?? anotherAgent as? Person
		if let cat = cat, let person = person {
			if cat.type != .domestic && person.isAtHouse {
				return true
			}
		}
		return false
	}
	
	private func isOneAgentPersonAtHomeAndTheOtherPersonOutside(_ agent: Agent, _ anotherAgent: Agent) -> Bool {
		if let person = agent as? Person, let otherPerson = anotherAgent as? Person {
			if person.isAtHouse && !otherPerson.isAtHouse {
				return true
			} else if !person.isAtHouse && otherPerson.isAtHouse {
				return true
			}
		}
		return false
	}
	
	private func isOneAgentDomesticCatAndOtherNonDomestic(_ agent: Agent, _ anotherAgent: Agent) -> Bool {
		if let cat = agent as? Cat, let otherCat = anotherAgent as? Cat {
			if cat.type == .domestic && otherCat.type != .domestic {
				return true
			} else if cat.type != .domestic && otherCat.type == .domestic {
				return true
			}
		}
		return false
	}
	
	private func isOneAgentDomesticCatAndTheOtherPersonOutside(_ agent: Agent, _ anotherAgent: Agent) -> Bool {
		let cat = agent as? Cat ?? anotherAgent as? Cat
		let person = agent as? Person ?? anotherAgent as? Person
		if let cat = cat, let person = person {
			if cat.type == .domestic && !person.isAtHouse {
				return true
			}
		}
		return false
	}
	
	private func areBothAgentsAtHomeAndInDifferentHouses(_ agent: Agent, _ anotherAgent: Agent) -> Bool {
		return areAgentsPersonsAtDifferentHouses(agent, anotherAgent)
			|| areAgentsDomesticCatsAtDifferentHouses(agent, anotherAgent)
			|| areAgentsDomesticCatAndPersonAtDifferentHouses(agent, anotherAgent)
	}
	
	private func areAgentsPersonsAtDifferentHouses(_ agent: Agent, _ anotherAgent: Agent) -> Bool {
		if let person = agent as? Person, let otherPerson = anotherAgent as? Person {
			if person.isAtHouse && otherPerson.isAtHouse && person.household != otherPerson.household {
				return true
			}
		}
		return false
	}
	
	private func areAgentsDomesticCatsAtDifferentHouses(_ agent: Agent, _ anotherAgent: Agent) -> Bool {
		if let cat = agent as? Cat, let otherCat = anotherAgent as? Cat {
			if cat.type == .domestic && otherCat.type == .domestic && cat.household != otherCat.household {
				return true
			}
		}
		return false
	}
	
	private func areAgentsDomesticCatAndPersonAtDifferentHouses(_ agent: Agent, _ anotherAgent: Agent) -> Bool {
		let cat = agent as? Cat ?? anotherAgent as? Cat
		let person = agent as? Person ?? anotherAgent as? Person
		if let cat = cat, let person = person {
			if cat.type == .domestic && person.isAtHouse && cat.household != person.household {
				return true
			}
		}
		return false
	}
	
	private func distance(between agent: Agent, and anotherAgent: Agent) -> CGFloat {
		let yDistance = agent.position.y - anotherAgent.position.y
		let xDistance = agent.position.x - anotherAgent.position.x
		return sqrt(pow(xDistance, 2) + pow(yDistance, 2))
	}
	
	private func probabilityOfInfection(between agent: Agent, and anotherAgent: Agent) -> CGFloat {
		guard agent.state == .susceptible || anotherAgent.state == .susceptible else {
			return 0	//At least one agent should be susceptible to return a non-zero probability.
		}
		if agent is Person && anotherAgent is Person {
			if agent.state == .infected || anotherAgent.state == .infected {
				return probabilities.betweenPeople.duringIncubation
			} else if agent.state == .infectedShowingSymptoms || anotherAgent.state == .infectedShowingSymptoms {
				return probabilities.betweenPeople.afterIncubation
			}
		} else if agent is Cat && anotherAgent is Cat {
			if agent.state == .infected || anotherAgent.state == .infected {
				return probabilities.betweenCats.duringIncubation
			} else if agent.state == .infectedShowingSymptoms || anotherAgent.state == .infectedShowingSymptoms {
				return probabilities.betweenCats.afterIncubation
			}
		} else {
			if agent.state == .infected || anotherAgent.state == .infected {
				return probabilities.betweenPersonAndCat.duringIncubation
			} else if agent.state == .infectedShowingSymptoms || anotherAgent.state == .infectedShowingSymptoms {
				return probabilities.betweenPersonAndCat.afterIncubation
			}
		}
		return 0
	}
}

extension InfectionStatusUpdater {
	fileprivate struct AgentHashableDecorator: Hashable {
		let agent: Agent
		static func == (lhs: AgentHashableDecorator, rhs: AgentHashableDecorator) -> Bool {
			return ObjectIdentifier(lhs.agent) == ObjectIdentifier(rhs.agent)
		}
		func hash(into hasher: inout Hasher) {
			hasher.combine(ObjectIdentifier(agent))
		}
	}
}

