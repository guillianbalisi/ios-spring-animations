import Foundation

let epsilon = 0.001
let minDuration = 0.01
let maxDuration = 10.0
let minDamping = Double.leastNormalMagnitude
let maxDamping = 1.0

public func approximateRoot(function: (Double) -> Double, derivative: (Double) -> Double, initialGuess: Double, times: Int = 12) -> Double {
	var result = initialGuess
	for _ in 1 ... times {
		result = result - function(result) / derivative(result)
	}
	return result
}

public func angularFrequency(undampedFrequency: Double, dampingRatio: Double) -> Double {
	return undampedFrequency * sqrt(1 - pow(dampingRatio, 2))
}

public func computeDampingRatio(tension: Double, friction: Double, mass: Double = 1) -> Double {
	return friction / (2 * sqrt(mass * tension))
}

public struct Result {
	public var stiffness: Double
	public var damping: Double
}

public func computeDerivedCurveOptions(dampingRatio: Double, duration: Double, velocity: Double = 0, mass: Double = 1) -> Result {
	let dampingRatio = max(min(dampingRatio, maxDamping), minDamping)
	let duration = max(min(duration, maxDuration), minDuration)
	
	let envelope: (Double) -> Double
	let derivative: (Double) -> Double
	if dampingRatio < 1 {
		envelope = { undampedFrequency in
			let exponentialDecay = undampedFrequency * dampingRatio
			let currentDisplacement = exponentialDecay * duration
			let a = exponentialDecay - velocity
			let b = angularFrequency(undampedFrequency: undampedFrequency, dampingRatio: dampingRatio)
			let c = exp(-1 * currentDisplacement)
			return epsilon - (a / b) * c
		}
		derivative = { undampedFrequency in
			let exponentialDecay = undampedFrequency * dampingRatio
			let currentDisplacement = exponentialDecay * duration
			let d = currentDisplacement * velocity + velocity
			let e = pow(dampingRatio, 2) * pow(undampedFrequency, 2) * duration
			let f = exp(-1 * currentDisplacement)
			let g = angularFrequency(undampedFrequency: pow(undampedFrequency, 2), dampingRatio: dampingRatio)
			let factor: Double = -1 * envelope(undampedFrequency) + epsilon > 0 ? -1 : 1
			return factor * ((d - e) * f / g)
		}
	} else {
		envelope = { undampedFrequency in
			let a = exp(-1 * undampedFrequency * duration)
			let b = (undampedFrequency - velocity) * duration + 1
			return -1 * epsilon + a * b
		}
		derivative = { undampedFrequency in
			let a = exp(-1 * undampedFrequency * duration)
			let b = (velocity - undampedFrequency) * pow(duration, 2)
			return a * b
		}
	}
	var result = Result(stiffness: 100, damping: 10)
	let initialGuess = 5 / duration
	let undampedFrequency = approximateRoot(function: envelope, derivative: derivative, initialGuess: initialGuess)
	result.stiffness = pow(undampedFrequency, 2) * mass
	result.damping = dampingRatio * 2 * sqrt(mass * result.stiffness)
	return result
}
