//
//  RippledProtocol.swift
//  RippleEffect
//
//  Created by 박준현 on 2022/06/25.
//

import UIKit

// MARK: RippledProtocol
protocol RippledProtocol: UIView {
    /// ripple 효과 색상
    var rippleColor: UIColor? { get set }
    /// ripple 효과의 alpha값
    var rippleAlpha: CGFloat { get set }
    var rippleLayer: RippleLayer { get }
    
    func touchesBeganForRipple(_ touches: Set<UITouch>, with event: UIEvent?)
}
extension RippledProtocol {
    var rippleLayer: RippleLayer {
        layer as! RippleLayer
    }
    var rippleColor: UIColor? {
        get {
            rippleLayer.rippleColor
        }
        
        set {
            rippleLayer.rippleColor = newValue
            setNeedsDisplay()
        }
    }
    var rippleAlpha: CGFloat {
        get {
            rippleLayer.rippleAlpha
        }
        
        set {
            rippleLayer.rippleAlpha = newValue
            setNeedsDisplay()
        }
    }
    
    func touchesBeganForRipple(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            rippleLayer.setRippleAt(point)
        }
    }
}

// MARK: RippleLayer
class RippleLayer: CALayer {
    var rippleColor: UIColor? = .white
    var rippleAlpha: CGFloat = 0.3
    
    private var circleLayer: CAShapeLayer?
    
    fileprivate func setRippleAt(_ point: CGPoint) {
        self.circleLayer?.removeFromSuperlayer()
        
        let radius = radiusForRippleCircle(point)
        
        //ripple 효과를 보여줄 원형 layer
        let circle = CAShapeLayer()
        circle.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circle.position = CGPoint(x: point.x, y: point.y)
        circle.path = UIBezierPath(arcCenter: CGPoint(x: circle.frame.width / 2, y: circle.frame.height / 2), radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
        circle.fillColor = rippleColor?.cgColor
        circle.opacity = 0
        
        self.masksToBounds = true
        self.addSublayer(circle)
        self.circleLayer = circle
        
        circle.add(rippleAnimation(), forKey: "ripple")
    }
    
    //터치한 위치를 기준으로 View의 상하좌우 간격 중 가장 긴 간격이 radius
    private func radiusForRippleCircle(_ point: CGPoint) -> CGFloat {
        let distanceX: CGFloat = max(self.frame.width - point.x, point.x)
        let distanceY: CGFloat = max(self.frame.height - point.y, point.y)
        return max(distanceX, distanceY)
    }
    
    //완성된 ripple Animation
    private func rippleAnimation() -> CAAnimationGroup {
        let animationGroup: CAAnimationGroup = CAAnimationGroup()
        animationGroup.duration = 0.45
        animationGroup.fillMode = .forwards
        
        let showingDuration: CGFloat = 0.3
        animationGroup.animations = [sizingAnimation(duration: showingDuration),
             showingAlphaAnimation(duration: showingDuration),
                                     hidingAlphaAnimation(beginTime: showingDuration, duration: 0.15)
        ]
        animationGroup.beginTime = CACurrentMediaTime()
        return animationGroup
    }
    
    //circle 등장 시 사이즈 확장 애니메이션
    private func sizingAnimation(duration: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = duration
        animation.beginTime = 0
        animation.fillMode = .forwards
        return animation
    }
    
    //circle 등장 시 alpha 애니메이션
    private func showingAlphaAnimation(duration: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0
        animation.toValue = rippleAlpha
        animation.duration = duration
        animation.beginTime = 0
        animation.fillMode = .forwards
        return animation
    }
    
    //circle 사라질 시 alpha 애니메이션
    private func hidingAlphaAnimation(beginTime: CGFloat, duration: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = rippleAlpha
        animation.toValue = 0
        animation.duration = duration
        animation.beginTime = beginTime
        animation.fillMode = .forwards
        return animation
    }
}


// MARK: RippledButton
class RippledButton: UIButton, RippledProtocol {
    
    override class var layerClass: AnyClass {
        RippleLayer.self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesBeganForRipple(touches, with: event)
    }
}
