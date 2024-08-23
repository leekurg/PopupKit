//
//  PassThroughUIWindow.swift
//
//
//  Created by Илья Аникин on 23.08.2024.
//

import UIKit

/// A ``UIWindow`` class, which is passing a touch event down the Responer Chain hierarchy when there is no view within that has been touched.
public final class PassThroughUIWindow: UIWindow {
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == hitView ? nil : hitView
    }
}
