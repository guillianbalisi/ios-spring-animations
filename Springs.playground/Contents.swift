import UIKit
import PlaygroundSupport

// Setup the playground view
let view = UIView(frame: CGRect(x: 0, y: 0, width: 600, height: 500))
view.backgroundColor = .white
PlaygroundPage.current.liveView = view

// Create the two layers
var layerA = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
var layerB = UIView(frame: CGRect(x: 0, y: 250, width: 200, height: 200))
layerA.backgroundColor = .red
layerB.backgroundColor = .blue

// Add them to the view
view.addSubview(layerA)
view.addSubview(layerB)

let duration: TimeInterval = 3
let dampingRatio: CGFloat = 0.25

// Standard UIView animate API: https://developer.apple.com/documentation/uikit/uiview/1622594-animate
UIView.animate(withDuration: duration,
               delay: 0,
               usingSpringWithDamping: dampingRatio,
               initialSpringVelocity: 0, options: [],
               animations: {
                layerA.frame.origin.x = 300
               },
               completion: nil)

// Animation using CASpringAnimation: https://developer.apple.com/documentation/quartzcore/caspringanimation
let animation = CASpringAnimation(keyPath: "position.x")

// We're animating the center, so adjust the animation from and to values for that
animation.fromValue = 0 + layerB.frame.midX
let toValue = 300 + layerB.frame.midX
animation.toValue = toValue

let result = computeDerivedCurveOptions(dampingRatio: Double(dampingRatio), duration: duration)

animation.stiffness = CGFloat(result.stiffness)
animation.damping = CGFloat(result.damping)

// Mass is always 1 on iOS, initialVelocity is only needed
// if you start an animation when the is view already moving (i.e. at the end of a drag)
animation.mass = 1
animation.initialVelocity = 0
animation.beginTime = 0
animation.duration = animation.settlingDuration

CATransaction.setCompletionBlock({
    layerB.layer.position.x = toValue
})
layerB.layer.add(animation, forKey: nil)
CATransaction.commit()
