//
//  PassThroughUIWindow.swift
//
//
//  Created by Илья Аникин on 23.08.2024.
//

import UIKit

/// A ``UIWindow`` class, which is passing a touch event down the Responer Chain hierarchy when there is no view within that has been touched.
public final class PassThroughUIWindow: UIWindow {
    // original
//    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        guard let hitView = super.hitTest(point, with: event) else { return nil }
//        return rootViewController?.view == hitView ? nil : hitView
//    }
}

// MARK: -  iOS 18 broken hitTest workaround https://forums.developer.apple.com/forums/thread/762292
// Known issues: unresponsive backround views when presentation is active
extension PassThroughUIWindow {
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if #available(iOS 18, *) {
            return super.hitTest(point, with: event)
        } else {
            guard let hit = super.hitTest(point, with: event) else {
                return .none
            }
            return rootViewController?.view == hit ? .none : hit
        }
    }

    private static func _hitTest(
        _ point: CGPoint,
        with event: UIEvent?,
        view: UIView,
        depth: Int = 0
    ) -> Optional<(view: UIView, depth: Int)> {
        var deepest: Optional<(view: UIView, depth: Int)> = .none
        
        /// views are ordered back-to-front
        for subview in view.subviews.reversed() {
            let converted = view.convert(point, to: subview)
            
            guard subview.isUserInteractionEnabled,
                  !subview.isHidden,
                  subview.alpha > 0,
                  subview.point(inside: converted, with: event)
            else {
                continue
            }
            
            let result = if let hit = Self._hitTest(
                converted,
                with: event,
                view: subview,
                depth: depth + 1
            ) {
                hit
            } else  {
                (view: subview, depth: depth)
            }
            
            if case .none = deepest {
                deepest = result
            } else if let current = deepest, result.depth > current.depth {
                deepest = result
            }
        }
        
        return deepest
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if #available(iOS 18, *) {
            guard let view = rootViewController?.view else {
                return false
            }
            
            let hit = Self._hitTest(
                point,
                with: event,
                view: subviews.count > 1 ? self : view
            )
            
            return hit != nil
        } else {
            return super.point(inside: point, with: event)
        }
    }
}
